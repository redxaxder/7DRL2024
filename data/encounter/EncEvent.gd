class_name EncEvent

# constructors for events
static func move_event(timestamp:int , actor: CombatEntity, move_to: Vector2) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEvent.EventKind.Move
	set_actor(evt, actor)
	evt.target_location = move_to
	evt.timestamp = timestamp
	print("moved to: {0},{1} {2} ".format([move_to.x, move_to.y, evt.actor_idx]))
	return evt

static func attack_event(timestamp: int, actor: CombatEntity, target: CombatEntity, damage) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEvent.EventKind.Attack
	set_actor(evt, actor)
	set_target(evt, target)
	evt.damage = damage
	evt.timestamp = timestamp
	return evt

static func miss_event(timestamp: int, actor: CombatEntity, target: CombatEntity) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEvent.EventKind.Attack
	set_actor(evt, actor)
	set_target(evt, target)
	evt.timestamp = timestamp
	return evt

static func death_event(timestamp: int, actor: CombatEntity) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEvent.EventKind.Death
	set_actor(evt, actor)
	evt.timestamp = timestamp
	return evt
	
static func damage_event(timestamp: int, target: CombatEntity, damage: int) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEvent.EventKind.Damage
	set_target(evt, target)
	evt.timestamp = timestamp
	evt.damage = damage
	return evt

static func ability_event(timestamp: int, actor: CombatEntity, ability: Ability, target: Vector2) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEvent.EventKind.AbilityActivation
	set_actor(evt, actor)
	evt.target_location = target
	evt.ability = ability
	evt.ab_name = ability.name
	evt.timestamp = timestamp
	return evt

static func set_actor(evt: EncounterEvent, actor: CombatEntity) -> EncounterEvent:
	evt.actor_idx = actor.entity_index
	evt.actor_name = actor.name
	return evt

static func set_target(evt: EncounterEvent, target: CombatEntity) -> EncounterEvent:
	evt.target_idx = target.entity_index
	evt.target_name = target.name
	return evt
