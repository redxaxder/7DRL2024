class_name EncEvent

# constructors for events
static func event_stub(timestamp: float, kind: int) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = kind
	evt.timestamp = timestamp
	return evt

static func move_event(timestamp: float, actor: CombatEntity, move_to: Vector2) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEventKind.Kind.Move
# warning-ignore:return_value_discarded
	set_actor(evt, actor)
	evt.target_location = move_to
	evt.timestamp = timestamp
	return evt

static func attack_event(timestamp: float, actor: CombatEntity, target: CombatEntity, damage: int, is_crit: bool, element: int) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEventKind.Kind.Attack
# warning-ignore:return_value_discarded
	set_actor(evt, actor)
# warning-ignore:return_value_discarded
	set_target(evt, target)
	evt.damage = max(1,damage)
	evt.is_crit = is_crit
	evt.timestamp = timestamp
	evt.element = element
	return evt

static func miss_event(timestamp: float, actor: CombatEntity, target: CombatEntity) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEventKind.Kind.Miss
# warning-ignore:return_value_discarded
	set_actor(evt, actor)
# warning-ignore:return_value_discarded
	set_target(evt, target)
	evt.timestamp = timestamp
	return evt

static func death_event(timestamp: float, killer: CombatEntity, victim: CombatEntity) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEventKind.Kind.Death
# warning-ignore:return_value_discarded
	set_target(evt, victim)
# warning-ignore:return_value_discarded
	set_actor(evt, killer)
	evt.timestamp = timestamp
	return evt
# EncEvent.stat_change_event
static func stat_change_event(timestamp: float, source: CombatEntity, target: CombatEntity, stat: int, damage: int) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEventKind.Kind.StatChange
# warning-ignore:return_value_discarded
	set_target(evt, target)
# warning-ignore:return_value_discarded
	set_actor(evt, source)
	evt.timestamp = timestamp
	evt.damage = damage
	evt.stat = stat
	return evt
static func damage_event(timestamp: float, source: CombatEntity, target: CombatEntity, damage: int, is_crit: bool, element: int) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEventKind.Kind.Damage
# warning-ignore:return_value_discarded
	set_target(evt, target)
# warning-ignore:return_value_discarded
	set_actor(evt, source)
	evt.timestamp = timestamp
	evt.is_crit = is_crit
					
	var modified_damage = float(damage)
	
	var source_multiplier = source.stats.get_elemental_power_multiplier(element)
	modified_damage *= source_multiplier
	
	var resist_multiplier = target.element_resist_multiplier(element)
	modified_damage *= resist_multiplier
	
	evt.damage = max(1,modified_damage)
	evt.element = element
	return evt

static func bloodied_event(timestamp: float, source: CombatEntity, target: CombatEntity) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEventKind.Kind.Bloodied
# warning-ignore:return_value_discarded
	set_target(evt, target)
# warning-ignore:return_value_discarded
	set_actor(evt, source)
	evt.timestamp = timestamp
	return evt

static func ability_event(timestamp: float, actor: CombatEntity, ability: Ability, target: Vector2, element: int) -> EncounterEvent:
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
	evt.displayed_radius = ability.radius(actor.stats)
	return evt

static func reaction_event(timestamp: float, actor: CombatEntity, ability: Ability, target: CombatEntity, target_location: Vector2) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	evt.kind = EncounterEventKind.Kind.PrepareReaction
# warning-ignore:return_value_discarded
	set_actor(evt, actor)
	if target != null:
# warning-ignore:return_value_discarded
		set_target(evt, target)
	else:
		evt.target_location = target_location
	evt.ability = ability
	evt.ab_name = ability.name
	evt.timestamp = timestamp
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
