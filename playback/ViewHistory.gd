extends Control

export var history: Resource = null
export var cursor: int = 0

func _ready():
	var some_events = []
	for _i in 10:
		var some_event = EncounterEvent.new()
		some_event.delta = (randi() % 5) - 2
		some_events.append(some_event)
	var state0 = EncounterState.new()
	history = roll_up(state0, some_events)
	get_node("%to_start").connect("button_down", self, "to_start")
	get_node("%to_end").connect("button_down", self, "to_end")

	var progressbar = get_node("%progress_bar")
	progressbar.min_value = 0
	progressbar.max_value = history.states.size() - 1
	progressbar.step = 1
	progressbar.connect("scrolling", self, "progress_bar_scroll")

func roll_up(state0: EncounterState, events: Array) -> EncounterHistory:
	var h = EncounterHistory.new()
	h.states = [state0]
	h.events = events
	h.states.resize(events.size() + 1)
	for i in events.size():
		var e = events[i]
		var s = h.states[i]
		var next_s = DataUtil.update(DataUtil.dup_state(s),e)
		h.states[i+1] = next_s
	return h

func to_start():
	cursor = 0
	_refresh()

func to_end():
	cursor = history.states.size() - 1
	_refresh()

func next():
	cursor = min(cursor+1, history.states.size() - 1)
	_refresh()

func prev():
	cursor = max(cursor-1, 0)
	_refresh()

func progress_bar_scroll():
	var progressbar = get_node("%progress_bar")
	if cursor != progressbar.value:
		cursor = progressbar.value
		_refresh()

func _unhandled_input(event):
	if event.is_action_pressed("up"): next()
	if event.is_action_pressed("down"): prev()
	if event.is_action_pressed("right"): next()
	if event.is_action_pressed("left"): prev()

func _refresh():
	var i = history.states[cursor].i
	get_node("%Icon").position.x = i * 200
	var progressbar = get_node("%progress_bar")
	progressbar.value = cursor
