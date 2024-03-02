extends Control

export var history: Resource = null
export var cursor: int = 0

func _ready():
	var some_events = []
	for _i in 10:
		var some_event = EncounterEvent.new()
		some_event.delta = (randi() % 3) * 2 - 1
		some_events.append(some_event)
	var state0 = EncounterState.new()
	var sss = state0.duplicate()
	history = roll_up(state0, some_events)


func roll_up(state0: EncounterState, events: Array) -> EncounterHistory:
	var history = EncounterHistory.new()
	history.states = [state0]
	history.events = events
	history.states.resize(events.size() + 1)
	for i in events.size():
		var e = events[i]
		var s = history.states[i]
		var next_s = e.update(s)
		prints("LOOP:", "{0} + {1} -> {2}".format([s.i, e.delta, next_s.i]) )
		assert(next_s.i == s.i + e.delta)
		history.states[i+1] = next_s
		assert(history.states[i+1].i == history.states[i].i + events[i].delta)
	return history


func _unhandled_input(event):
	if event.is_action_pressed("up"):
		cursor = min(cursor+1, history.states.size() - 1)
		_refresh()
	if event.is_action_pressed("down"):
		cursor = max(cursor-1, 0)
		_refresh()
	if event.is_action_pressed("right"):
		pass
	if event.is_action_pressed("left"):
		pass

func _refresh():
	var i = history.states[cursor].i
	$Icon.position.x = i * 200
	$cursor.text = "cursor %d" % cursor
	$next_delta.text = "next_delta "
	if history.events[cursor] != null:
		$next_delta.text += "%d" % history.events[cursor].delta
	$i.text = "i %d" % i
