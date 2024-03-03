extends Control

const turn_limit = 100
var playback_speed = 5

var d
var cursor: int = 0
var history: EncounterHistory
func _ready():
	randomize()
# warning-ignore:return_value_discarded
	get_node("%to_start").connect("button_down", self, "to_start")
# warning-ignore:return_value_discarded
	get_node("%to_end").connect("button_down", self, "to_end")
# warning-ignore:return_value_discarded
	get_node("%step_forward").connect("button_down", self, "next")
# warning-ignore:return_value_discarded
	get_node("%step_backward").connect("button_down", self, "prev")
# warning-ignore:return_value_discarded
	get_node("%play").connect("button_down", self, "play")
# warning-ignore:return_value_discarded
	get_node("%pause").connect("button_down", self, "pause")

	var progressbar = get_node("%progress_bar")
	progressbar.step = 1
	progressbar.min_value = 0
	progressbar.connect("scrolling", self, "progress_bar_scroll")

	var driver = EncounterDriver.new()
	driver.initialize()
	while driver.tick() and driver.history.size() < turn_limit:
		pass
	

	history = driver.history
#	var last_state = history.get_states().pop_back()
#	var it = last_state.get_player().is_alive()

	progressbar.max_value = history.get_states().size() - 1

	var events = driver.history.get_events()
	var n = events.size()
	for i in n:
		var event = events[i]
		var log_node = preload("res://playback/log_line.tscn").instance()
		log_node.set_label(driver.event_text(event))
		log_node.connect("pressed", self, "log_line_click", [i])
		log_node.visible = event.is_displayed()
		get_node("%combat_log").add_child(log_node)
	_hard_refresh()

func play():
	get_node("%play").visible = false
	get_node("%pause").visible = true
	set_process(true)

func pause():
	get_node("%play").visible = true
	get_node("%pause").visible = false
	set_process(false)

var elapsed = 0
func _process(delta):
	elapsed += delta * playback_speed
	if elapsed >= 1:
		elapsed -= 1
		step()

func to_start():
	pause()
	cursor = 0
	elapsed = 0
	_refresh()

func to_end():
	pause()
	cursor = history.get_states().size() - 1
	_refresh()

func next():
	pause()
	step()

func step():
	var next = min(cursor+1, history.get_states().size() - 1) 
	if next > cursor:
		cursor = next
		_refresh()
	else:
		pause()
	
func prev():
# warning-ignore:narrowing_conversion
	pause()
	cursor = max(cursor-1, 0)
	_refresh()

func log_line_click(i):
	pause()
	if cursor != i:
		cursor = i
		_refresh()

func progress_bar_scroll():
	var progressbar = get_node("%progress_bar")
	pause()
	if cursor != progressbar.value:
		cursor = progressbar.value
		_refresh()

func _unhandled_input(event):
	if event.is_action_pressed("up"): to_start()
	if event.is_action_pressed("down"): to_end()
	if event.is_action_pressed("right"): next()
	if event.is_action_pressed("left"): prev()
	if event.is_action_pressed("toggle"):
		if get_node("%play").visible: play()
		elif get_node("%pause").visible: pause()
	
func _gui_input(event):
	if event.is_action_pressed("ui_up"): to_start()
	if event.is_action_pressed("ui_down"): to_end()
	if event.is_action_pressed("ui_right"): next()
	if event.is_action_pressed("ui_left"): prev()

var sprites = []
func allocate_sprites(s: EncounterState):
	var n = s.actors.size()
	sprites = []
	sprites.resize(n)
	for i in n:
		var actor = s.actors[i]
		var sprite = Actor.get_sprite(actor.actor_type).instance()
		sprites[i] = sprite
		get_node("%display").add_child(sprite)
		sprite.position = Vector2(100,100)


# hard refresh for viewing new encounters
# ordinary refresh for viewing different state of same encounter
func _hard_refresh(): _refresh(true)
func _refresh(_hard_refresh: bool = false):
	var display = get_node("%display")
	var display_size: Vector2 = display.get_rect().size
	var tile_envelope = Constants.TILE_SIZE + Constants.TILE_MARGIN
	var tile_bounds = display_size / Constants.MAP_BOUNDARIES.size
	var scale_factor = floor(min(tile_bounds.x, tile_bounds.y)/ tile_envelope)
	var scaled_size = scale_factor * tile_envelope
	var current_state = history.get_states()[cursor]

	var events =  history.get_events()
	var time = events[min(cursor, events.size() - 1)].timestamp
	get_node("%timestamp").text = "%d" % time
	
	if _hard_refresh:
		allocate_sprites(current_state)

	var n = current_state.actors.size()
	for i in n:
		var actor = current_state.actors[i]
		sprites[i].position = actor.location * scaled_size
		sprites[i].scale = Vector2(scale_factor, scale_factor)
		sprites[i].visible = actor.is_alive()

	var progressbar = get_node("%progress_bar")
	progressbar.value = cursor
	var loglines = get_node("%combat_log").get_children()
	for i in loglines.size():
		loglines[i].highlighted = i == cursor
