extends Resource

class_name EncounterHistory
export var states: Array = [] # Array of EncounterState
export var events: Array = [] # Array of EncounterEvent
# events[i] is the event that causes a transition from
# state[i] to state[i+1]

func add_state(st: EncounterState):
	states.append(states)
	for i in events.size():
		var e = events[i]
		assert(e is EncounterEvent)

func add_event(evt: EncounterEvent):
	events.append(evt)
	for i in events.size():
		var e = events[i]
		assert(e is EncounterEvent)
