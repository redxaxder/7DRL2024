extends Resource

class_name EncounterHistory
export var _states: Array = DataUtil.new_array()
export var _events: Array = DataUtil.new_array()
# events[i] is the event that causes a transition from
# state[i] to state[i+1]

func initial() -> EncounterState:
	return _states[0]

func final() -> EncounterState:
	return _states[-1]

func size():
	return _states.size()

func add_state(st: EncounterState):
	_states.append(st)

func add_event(evt: EncounterEvent):
	_events.append(evt)

func get_state(i: int) -> EncounterState:
	return _states[clamp(i, 0, _states.size() - 1)]

func get_event(i: int) -> EncounterEvent:
	return _events[clamp(i, 0 , _events.size() - 1)]
