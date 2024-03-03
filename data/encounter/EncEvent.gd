
# constructors for events
static func move_event(timestamp:int , actor: CombatEntity, move_to: Vector2) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEvent.EventKind.Move
	evt.actor_idx = actor.entity_index
	evt.target_location = move_to
	evt.timestamp = timestamp
	return evt

static func attack_event(timestamp: int, actor: CombatEntity, target: CombatEntity, damage) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEvent.EventKind.Attack
	evt.actor_idx = actor.entity_index
	evt.target_idx = target.entity_index
	evt.damage = damage
	evt.timestamp = timestamp
	return evt

static func miss_event(timestamp: int, actor: CombatEntity, target: CombatEntity) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEvent.EventKind.Attack
	evt.actor_idx = actor.entity_index
	evt.target_idx = target.entity_index
	evt.timestamp = timestamp
	return evt

static func death_event(timestamp: int, actor: CombatEntity) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEvent.EventKind.Death
	evt.actor_idx = actor.entity_index
	evt.timestamp = timestamp
	return evt
