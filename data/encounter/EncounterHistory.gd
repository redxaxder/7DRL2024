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
	if i < 0 or i >= _states.size(): return null
	return _states[i]

func get_event(i: int) -> EncounterEvent:
	if i < 0 or i >= _events.size(): return null
	return _events[i]
