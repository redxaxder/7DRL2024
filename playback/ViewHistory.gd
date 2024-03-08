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
var marked_end = false

signal seen_end(state)
signal updated(encounter_state, encounter_event)

func _ready():
# warning-ignore:return_value_discarded
	get_node("%to_start").connect("pressed", self, "to_start")
# warning-ignore:return_value_discarded
	get_node("%to_end").connect("pressed", self, "to_end")
# warning-ignore:return_value_discarded
	get_node("%step_forward").connect("pressed", self, "next")
# warning-ignore:return_value_discarded
	get_node("%step_backward").connect("pressed", self, "prev")
# warning-ignore:return_value_discarded
	get_node("%play").connect("pressed", self, "play")
# warning-ignore:return_value_discarded
	get_node("%pause").connect("pressed", self, "pause")
	var combat_log = get_node("%combat_log")
	combat_log.connect("mouse_entered",self, "log_hover", [true])
	combat_log.connect("mouse_exited",self, "log_hover", [false])

	var progressbar = get_node("%progress_bar")
	progressbar.step = 1
	progressbar.min_value = 0
	progressbar.connect("scrolling", self, "progress_bar_scroll")

func _end():
	if !history: return 0
	return get_node("%combat_log").get_child_count()-1

func clear():
	pause()
	cursor = 0
	history = null
	map = null
	for c in get_node("%combat_log").get_children():
		c.queue_free()
	for c in get_children():
		c.visible = false

var _victory_messages = []
func view(_history: EncounterHistory, _map: Map, victory_messages):
	for c in get_children():
		c.visible = true
	history = _history
	max_cursor = 0
	map = _map
	marked_end = false

	var history_amount = history.size() - 1
	for i in history_amount:
		var event = history.get_event(i)
		add_log_message(event_text(event), i, event)
	_victory_messages = victory_messages
	# _end()
	play()

	var progressbar = get_node("%progress_bar")
	progressbar.max_value = _end()
	_refresh()

func event_text(evt: EncounterEvent) -> String:
	match evt.kind:
		EncounterEventKind.Kind.Spawn:
			return "{time}: {tn} appeared.".format(evt.dict())
		EncounterEventKind.Kind.EncounterStart:
			return "{time}: Start!".format(evt.dict())
		EncounterEventKind.Kind.Attack:
			if evt.damage > 0:
				return "{time}: {an} attacked {tn}!".format(evt.dict())
			else:
				return "{time}: {an} missed {tn}!".format(evt.dict())
		EncounterEventKind.Kind.Miss:
			return "{time}: {an} missed {tn}!".format(evt.dict())
		EncounterEventKind.Kind.Bloodied:
			return "{time}: {tn} fell to low hp".format(evt.dict())
		EncounterEventKind.Kind.Death:
			return "{time}: {tn} died!".format(evt.dict())
		EncounterEventKind.Kind.Move:
			return "{time}: {an} moved -> {loc}".format(evt.dict())
		EncounterEventKind.Kind.AbilityActivation:
			if evt.ability.activation.trigger == SkillsCore.Trigger.Action:
				return "{time}: {an} activated ability {m}".format(evt.dict())
			else:
				return "{time}: {an} reacted with {m}".format(evt.dict())
		EncounterEventKind.Kind.Damage:
			if evt.is_crit:
				return "{time}: Critical hit! {tn} took {d} {el}damage!!!".format(evt.dict())
			else:
				return "{time}: {tn} took {d} {el}damage!".format(evt.dict())
		EncounterEventKind.Kind.StatChange:
			var gained = "gained"
			if evt.damage < 0:
				gained = "lost"
			return str("{time}: {tn} ", gained, " {d} ",Stat.NAME[evt.stat]).format(evt.dict())
		EncounterEventKind.Kind.PrepareReaction:
			return "{time}: {an} prepared reaction: {m}".format(evt.dict())
	push_warning("Event not handled by logger! {0}".format([evt.kind]))
	return ""


func add_log_message(text: String, index: int, evt: EncounterEvent):
	var log_node = preload("res://playback/log_line.tscn").instance()
	
	if evt:
		if evt.kind == EncounterEventKind.Kind.AbilityActivation:
			log_node.modulate = Color.cyan
		if evt.kind == EncounterEventKind.Kind.Death:
			log_node.modulate = Color.red
	else:
		log_node.modulate = Color("#ff2bfa")
	
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
	if cursor != i:
		cursor = i
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
	while next < n-1 and !EncounterEventKind.is_animated(history.get_event(next).kind):
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
	max_cursor = next_max
	if cursor == _end() and history.is_done and !marked_end:
		marked_end = true
		emit_signal("seen_end", history.final())
		if history.final().get_player().cur_hp > 0:
			for i in _victory_messages.size():
				add_log_message(_victory_messages[i], i + history.size() - 1, null)
	if log_is_hovered and last_log_hover >= 0:
		index = last_log_hover
# warning-ignore:narrowing_conversion
	var current_event = history.get_event(index)
	var time = 0
	if current_event:
		time = current_event.timestamp
	get_node("%timestamp").text = "%d" % (round(time*10) / 10.0)
	var progressbar = get_node("%progress_bar")
	progressbar.value = index
	var combat_log = get_node("%combat_log")
	var loglines = combat_log.get_children()
	var highlighted_line = 0
	for i in loglines.size():
		var displayed_default = EncounterEventKind.is_displayed(history.get_event(i).kind)
		var should_show = show_extra_history or displayed_default
		loglines[i].visible = should_show and i <= max_cursor
		if i <= index and loglines[i].visible:
			loglines[highlighted_line].highlighted = false
			highlighted_line = i
			loglines[i].highlighted = true
		else:
			loglines[i].highlighted = false
		if i == index and loglines[i].visible:
			call_deferred("update_scroll", i)
	var current_state = history.get_state(index+1)
	emit_signal("updated", current_state, current_event)
	
# EncounterHistory.get_state lines 24 change out of bounds code to clamp

var scroll_min_bound = 0
var scroll_max_bound = 0
func update_scroll(i: int):
	var rect = get_node("%combat_log").get_child(i).get_rect()
	scroll_min_bound = rect.position.y + rect.size.y - $ScrollContainer.rect_size.y
	scroll_max_bound = rect.position.y
	call_deferred("chain_scroll",2)

func chain_scroll(chain: int):
	var vs = $ScrollContainer.scroll_vertical
	$ScrollContainer.scroll_vertical = clamp(vs, scroll_min_bound, scroll_max_bound)
	if chain > 0:
		call_deferred("chain_scroll", chain -1)
