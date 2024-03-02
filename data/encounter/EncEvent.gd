
# constructors for events
static func move_event(actor: CombatEntity, move_to: Vector2) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEvent.EventKind.Move
	evt.actor_idx = actor.entity_index
	evt.target_location = move_to
	return evt

static func attack_event(actor: CombatEntity, target: CombatEntity, damage) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEvent.EventKind.Attack
	evt.actor_idx = actor.entity_index
	evt.target_idx = target.entity_index
	evt.damage = damage
	return evt

static func miss_event(actor: CombatEntity, target: CombatEntity) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEvent.EventKind.Attack
	evt.actor_idx = actor.entity_index
	evt.target_idx = target.entity_index
	return evt

static func death_event(actor: CombatEntity) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEvent.EventKind.Death
	evt.actor_idx = actor.entity_index
	return evt
