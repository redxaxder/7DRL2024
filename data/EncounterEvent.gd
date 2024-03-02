extends Resource

class_name EncounterEvent

export var delta: int = 0

func update(state: EncounterState) -> EncounterState:
	prints("UPDATE", state, state.i)
	var next = state.duplicate(true)
	#mysteriously, without this godot is unable to recognize that next
	#is the same type of resource as state
	next.set_script(preload("res://data/EncounterState.gd"))
	assert(next is EncounterState)
	next.i = state.i
	
	var tmp = next.i + delta
	next.i = tmp # clamp(tmp, 0, 5)
	assert(next != null)
	return next
