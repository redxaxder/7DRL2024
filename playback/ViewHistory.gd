extends Control

var d
var cursor: int = 0
var history: EncounterHistory
func _ready():
# warning-ignore:return_value_discarded
	get_node("%to_start").connect("button_down", self, "to_start")
# warning-ignore:return_value_discarded
	get_node("%to_end").connect("button_down", self, "to_end")
# warning-ignore:return_value_discarded
	get_node("%step_forward").connect("button_down", self, "next")
# warning-ignore:return_value_discarded
	get_node("%step_backward").connect("button_down", self, "prev")

	var progressbar = get_node("%progress_bar")
	progressbar.step = 1
	progressbar.min_value = 0
	progressbar.connect("scrolling", self, "progress_bar_scroll")

	var driver = EncounterDriver.new()
	driver.initialize()
	var player_is_alive = true
	while player_is_alive:
		player_is_alive = driver.tick()

	history = driver.history

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


func to_start():
	cursor = 0
	_refresh()

func to_end():
	cursor = history.get_states().size() - 1
	_refresh()

func next():
# warning-ignore:narrowing_conversion
	cursor = min(cursor+1, history.get_states().size() - 1)
	_refresh()

func prev():
# warning-ignore:narrowing_conversion
	cursor = max(cursor-1, 0)
	_refresh()

func log_line_click(i):
	if cursor != i:
		cursor = i
		_refresh()

func progress_bar_scroll():
	var progressbar = get_node("%progress_bar")
	if cursor != progressbar.value:
		cursor = progressbar.value
		_refresh()

func _unhandled_input(event):
	if event.is_action_pressed("up"): to_start()
	if event.is_action_pressed("down"): to_end()
	if event.is_action_pressed("right"): next()
	if event.is_action_pressed("left"): prev()
	
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
	var current_state = history.get_states()[cursor]
	if _hard_refresh:
		allocate_sprites(current_state)

	var n = current_state.actors.size()
	for i in n:
		var actor = current_state.actors[i]
		sprites[i].position = actor.location * 50

	var progressbar = get_node("%progress_bar")
	progressbar.value = cursor
	var loglines = get_node("%combat_log").get_children()
	for i in loglines.size():
		loglines[i].highlighted = i == cursor
