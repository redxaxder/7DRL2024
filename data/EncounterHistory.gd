extends Resource

class_name EncounterHistory
export var states: Array = [] # Array of EncounterState
export var events: Array = [] # Array of EncounterEvent
# events[i] is the action that causes a transition from
# state[i] to state[i+1]
