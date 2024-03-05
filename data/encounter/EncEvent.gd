class_name EncEvent

# constructors for events
static func move_event(timestamp:int , actor: CombatEntity, move_to: Vector2) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEventKind.Kind.Move
# warning-ignore:return_value_discarded
	set_actor(evt, actor)
	evt.target_location = move_to
	evt.timestamp = timestamp
	return evt

static func attack_event(timestamp: int, actor: CombatEntity, target: CombatEntity, damage: int, element: int) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEventKind.Kind.Attack
# warning-ignore:return_value_discarded
	set_actor(evt, actor)
# warning-ignore:return_value_discarded
	set_target(evt, target)
	evt.damage = max(1,damage)
	evt.timestamp = timestamp
	evt.element = element
	return evt

static func miss_event(timestamp: int, actor: CombatEntity, target: CombatEntity) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEventKind.Kind.Attack
# warning-ignore:return_value_discarded
	set_actor(evt, actor)
# warning-ignore:return_value_discarded
	set_target(evt, target)
	evt.timestamp = timestamp
	return evt

static func death_event(timestamp: int, killer: CombatEntity, victim: CombatEntity) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEventKind.Kind.Death
# warning-ignore:return_value_discarded
	set_target(evt, victim)
	set_actor(evt, killer)
	evt.timestamp = timestamp
	return evt
	
static func damage_event(timestamp: int, source: CombatEntity, target: CombatEntity, damage: int, element: int) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEventKind.Kind.Damage
# warning-ignore:return_value_discarded
	set_target(evt, target)
	set_actor(evt, source)
	evt.timestamp = timestamp
	evt.damage = max(1,damage)
	evt.element = element
	return evt

static func ability_event(timestamp: int, actor: CombatEntity, ability: Ability, target: Vector2, element: int) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEventKind.Kind.AbilityActivation
# warning-ignore:return_value_discarded
	set_actor(evt, actor)
	evt.target_location = target
	evt.ability = ability
	evt.ab_name = ability.name
	evt.timestamp = timestamp
	evt.element = element
	return evt

static func set_actor(evt: EncounterEvent, actor: CombatEntity) -> EncounterEvent:
	if actor:
		evt.actor_idx = actor.entity_index
		evt.actor_name = actor.name
	return evt

static func set_target(evt: EncounterEvent, target: CombatEntity) -> EncounterEvent:
	evt.target_idx = target.entity_index
	evt.target_location = target.location
	evt.target_name = target.name
	return evt
