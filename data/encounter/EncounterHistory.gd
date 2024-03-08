extends Resource

class_name EncounterHistory
#export var _states: Array = DataUtil.new_array()
export var _sparse: Array = DataUtil.new_array()
export var _events: Array = DataUtil.new_array()
var is_done = false
# events[i] is the event that causes a transition from
# state[i] to state[i+1]

const INTERVAL = 20

func initial() -> EncounterState:
	return get_state(0)# states[0]

func final() -> EncounterState:
	return get_state(_events.size())

func size():
	return _events.size()+1

func initialize(st: EncounterState):
#	_states = [st]
	_sparse = [st]

func add_event(st: EncounterState, evt: EncounterEvent):
#	_states.append(st)
	_events.append(evt)
	if _events.size() % INTERVAL == 0:
		_sparse.append(st)

func get_state(i: int) -> EncounterState:
	i = clamp(i, 0, _events.size())
	var k = i%INTERVAL
	i = i-k
	var s = _sparse[i/INTERVAL]
	var t = DataUtil.deep_dup(s)
	for n in k:
		EncounterCore.update(t, _events[i+n])
	return t

func get_event(i: int) -> EncounterEvent:
	return _events[clamp(i, 0 , _events.size() - 1)]
