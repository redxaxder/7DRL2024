extends Resource

class_name EncounterHistory
export var _states: Array = DataUtil.new_array()
export var _events: Array = DataUtil.new_array()
# events[i] is the event that causes a transition from
# state[i] to state[i+1]

func size():
	return _states.size()

func add_state(st: EncounterState):
	_states.append(st)

func add_event(evt: EncounterEvent):
	_events.append(evt)

func get_states() -> Array:
	return _states

func get_events() -> Array:
	return _events
