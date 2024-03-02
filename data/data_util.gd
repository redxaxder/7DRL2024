class_name DataUtil

static func dup_state(s: EncounterState) -> EncounterState:
	var new = EncounterState.new()
	#mysteriously, without this godot is unable to recognize that next
	#is the same type of resource as state
	new.set_script(preload("res://data/EncounterState.gd"))
	new.i = s.i
	return new

static func update(state: EncounterState, event: EncounterEvent) -> EncounterState:
	state.i = clamp(state.i + event.delta, 0, 10)
	return state
