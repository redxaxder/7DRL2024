extends Control

var playback_speed = 5

var show_extra_history = false setget set_show_extra_history
func set_show_extra_history(x):
	show_extra_history = x
	_refresh()

var cursor: int = 0
var max_cursor: int = 0
var history: EncounterHistory
var map: Map

signal updated(encounter_state, encounter_event)

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
	var combat_log = get_node("%combat_log")
	combat_log.connect("mouse_entered",self, "log_hover", [true])
	combat_log.connect("mouse_exited",self, "log_hover", [false])

	var progressbar = get_node("%progress_bar")
	progressbar.step = 1
	progressbar.min_value = 0
	progressbar.connect("scrolling", self, "progress_bar_scroll")

func _end():
	if !history: return 0
	return history.size() - 1

func clear():
	pause()
	cursor = 0
	history = null
	map = null
	for c in get_node("%combat_log").get_children():
		c.queue_free()
	for c in get_children():
		c.visible = false

func view(_history: EncounterHistory, _map: Map):
	for c in get_children():
		c.visible = true
	history = _history
	max_cursor = 0
	map = _map
	var progressbar = get_node("%progress_bar")
	progressbar.max_value = _end()

# warning-ignore:return_value_discarded
	add_log_message("0: Start!", 0)
	for i in _end():
		var event = history.get_event(i)
		var log_node = add_log_message(event_text(event), i)
	play()
	_refresh()

func event_text(evt: EncounterEvent) -> String:
	match evt.kind:
		EncounterEventKind.Kind.Attack:
			if evt.damage > 0:
				return "{time}: {an} attacked {tn}!".format(evt.dict())
			else:
				return "{time}: {an} missed {tn}!".format(evt.dict())
		EncounterEventKind.Kind.Death:
			return "{time}: {tn} died!".format(evt.dict())
		EncounterEventKind.Kind.Move:
			return "{time}: {an} moved! -> {loc}".format(evt.dict())
		EncounterEventKind.Kind.AbilityActivation:
			return "{time}: {an} activated ability {m}".format(evt.dict())
		EncounterEventKind.Kind.Damage:
			return "{time}: {tn} took {d} damage!".format(evt.dict())
		EncounterEventKind.Kind.PrepareReaction:
			return "{time}: {an} prepared reaction: {m}".format(evt.dict())
	push_warning("Event not handled by logger! {0}".format([evt.kind]))
	return ""


func add_log_message(text: String, index: int) -> Node:
	var log_node = preload("res://playback/log_line.tscn").instance()
	log_node.set_label(text)
	log_node.connect("pressed", self, "log_line_click", [index])
	get_node("%combat_log").add_child(log_node)
	log_node.connect("mouse_entered", self, "log_line_hover", [index])
	return log_node

var last_log_hover = -1
func log_line_hover(index: int):
	if last_log_hover != index:
		last_log_hover = index
		_refresh()

func log_line_click(i):
	pause()
	if cursor != i + 1:
		cursor = i + 1
		_refresh()

var log_is_hovered:bool = false
func log_hover(is_hovered: bool):
	log_is_hovered = is_hovered
	_refresh()

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
	if log_is_hovered:
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
	cursor = _end()
	_refresh()

func next():
	pause()
	step()

func step():
	var n = _end()
	var next = min(cursor+1,n)
	while next < n-1 and !history.get_event(next).is_animated():
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

func _refresh():
	if !history: return
	var index = cursor
	var next_max = max(max_cursor, cursor)
	var max_cursor_increased = next_max > max_cursor 
	max_cursor = next_max
	if log_is_hovered and last_log_hover >= 0:
		index = last_log_hover+1
	var current_event = history.get_event(max(index - 1, 0))
	var time = 0
	if current_event: time = current_event.timestamp
	get_node("%timestamp").text = "%d" % time
	var progressbar = get_node("%progress_bar")
	progressbar.value = index
	var combat_log = get_node("%combat_log")
	var loglines = combat_log.get_children()
	var highlighted_line = 0
	for i in loglines.size():
		var should_show = i == 0 or show_extra_history or history.get_event(i-1).is_displayed()
		loglines[i].visible = should_show and i <= max_cursor
		if i <= index and loglines[i].visible:
			loglines[highlighted_line].highlighted = false
			highlighted_line = i
			loglines[i].highlighted = true
		else:
			loglines[i].highlighted = false
		if i == max_cursor and max_cursor_increased:
			 # TODO (C?): scroll active log message into view generally, not just when max increases
			call_deferred("chain_scroll", 2)
	
	var current_state = history.get_state(index)
	emit_signal("updated", current_state, current_event)

func chain_scroll(chain: int):
	$ScrollContainer.scroll_vertical = get_node("%combat_log").rect_size.y
	if chain > 0:
		call_deferred("chain_scroll", chain -1)
