class_name DataUtil

static func dup_state(s: EncounterState) -> EncounterState:
	var new = EncounterState.new()
	#mysteriously, without this godot is unable to recognize that next
	#is the same type of resource as state
	new.set_script(preload("res://data/encounter/EncounterState.gd"))
	return new

static func update(state: EncounterState, event: EncounterEvent) -> EncounterState:
	match event.kind:
		EncounterEvent.EventKind.Move:
			state.set_location(event.actor_idx, event.target_location)
		EncounterEvent.EventKind.Attack:
			state.resolve_attack(event.actor_idx, event.target_idx, event.did_hit, event.damage)

	return state

static func new_array() -> Array:
	return []
