extends Control

var playback_speed = 5

var d
var cursor: int = 0
var history: EncounterHistory
var map: Map
func _ready():
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

func view(_history: EncounterHistory, _map: Map):
	cursor = 0
	history = _history
	map = _map
	var progressbar = get_node("%progress_bar")
	progressbar.max_value = history.get_states().size() - 1


	var events = history.get_events()
# warning-ignore:return_value_discarded
	for c in get_node("%combat_log").get_children():
		c.queue_free()
	add_log_message("0: Start!", 0)
	var n = events.size()
	for i in n:
		var event = events[i]
		var log_node = add_log_message(event_text(event), i)
		log_node.visible = event.is_displayed()
	play()
	_hard_refresh()

func event_text(evt: EncounterEvent) -> String:
	match evt.kind:
		EncounterEvent.EventKind.Attack:
			return "{time}: {a} attacked {t}! {d} damage!".format(evt.dict())
		EncounterEvent.EventKind.Death:
			return "{time}: {a} died!".format(evt.dict())
		EncounterEvent.EventKind.Move:
			return "{time}: {a} moved! -> {loc}".format(evt.dict())
		EncounterEvent.EventKind.AbilityActivation:
			return "{time}: {a} activated ability - {m}".format(evt.dict())
	push_warning("Event not handled by logger! {0}".format([evt.kind]))
	return ""


func add_log_message(text: String, index: int) -> Node:
	var log_node = preload("res://playback/log_line.tscn").instance()
	log_node.set_label(text)
	log_node.connect("pressed", self, "log_line_click", [index])
	get_node("%combat_log").add_child(log_node)
	return log_node

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
	if !history:
		set_process(false)
		return
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
	var n = history.get_states().size() - 1
	var next = min(cursor+1,n)
	while next < n-1 and !history.get_events()[next].is_animated():
		next += 1
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
		cursor = i + 1
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

# hard refresh for viewing new encounters
# ordinary refresh for viewing different state of same encounter
func _hard_refresh(): _refresh(true)
func _refresh(do_hard_refresh: bool = false):
	if !history: return
	var stateview = get_node("%state_view")
	var current_state = history.get_states()[cursor]

	if do_hard_refresh:
		stateview.init_view(current_state, map)
	else:
		stateview.update_view(current_state)

	var events =  history.get_events()
	var time = events[min(cursor, events.size() - 1)].timestamp
	get_node("%timestamp").text = "%d" % time

	var progressbar = get_node("%progress_bar")
	progressbar.value = cursor
	var loglines = get_node("%combat_log").get_children()
	var highlighted_line = 0
	for i in loglines.size():
		if i <= cursor and loglines[i].visible:
			loglines[highlighted_line].highlighted = false
			highlighted_line = i
			loglines[i].highlighted = true
		else:
			loglines[i].highlighted = false
