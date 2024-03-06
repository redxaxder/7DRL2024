class_name EncounterCore

static func update(state: EncounterState, event: EncounterEvent) -> Array: # [ EncounterEvent ]
	assert(event.target_location != Vector2(-99999,-99999))
	assert(event.actor_idx >= 0)
	var result = []

	match event.kind:
		EncounterEventKind.Kind.Move:
			if state.lookup_actor(event.target_location) == null:
				state.set_location(event.actor_idx, event.target_location)
		EncounterEventKind.Kind.Attack:
			var source = state.actors[event.actor_idx]
			var target = state.actors[event.target_idx]
			if event.damage > 0:
				result.append(deal_damage(source, target, event.damage, event.timestamp, event.element))
		EncounterEventKind.Kind.Death:
			state.remove_actor(event.target_idx)
		EncounterEventKind.Kind.AbilityActivation:
			result.append_array(handle_ability_activation(state, event))
		EncounterEventKind.Kind.Damage:
			var target = state.actors[event.target_idx]
# warning-ignore:narrowing_conversion
			var modified_damage = get_damage_with_element(state, event)
			modified_damage = max(modified_damage,1)
			state.resolve_attack(event.target_idx, modified_damage)
			if !target.is_alive():
				var killer = state.actors[event.actor_idx]
				result.append(EncEvent.death_event(event.timestamp, killer, target))
		EncounterEventKind.Kind.PrepareReaction:
			# these do not affect encounter state directly; the driver uses them to queue up AbilityActivations
			pass
	for reactor in state.actors:
		for reaction in reactor.event_reactions():
			if reaction.on_cooldown(): continue
			result.append_array(trigger_reaction(event.timestamp, state, event, reactor, reaction))
	return result

static func use_ability(actor: CombatEntity, target: Vector2, ability: Ability, timestamp: int) -> Array: # [ EncounterEvent ]
	if ability.on_cooldown():
		return []
	ability.use()
	return [EncEvent.ability_event(timestamp, actor, ability, target, ability.effect.element)]

static func deal_damage(source: CombatEntity, target: CombatEntity, damage: int, timestamp: int, element: int) -> EncounterEvent:
	assert(damage > 0)
	return EncEvent.damage_event(timestamp, source, target, damage, element)

static func get_damage_with_element(state: EncounterState, event: EncounterEvent) -> float:
	assert(event.kind == EncounterEventKind.Kind.Damage)
	var damage: float = float(event.damage)
	assert(damage > 0)
	var target = state.actors[event.target_idx]
	var resist_multiplier = target.element_resist_multiplier(event.element)
	damage *= resist_multiplier
	assert(damage > 0)
	return damage
	
static func handle_ability_activation(state: EncounterState, event: EncounterEvent) -> Array: # [ EncounterEvent ]
	var ability = event.ability #TODO: handle AOEs
	var target = state.lookup_actor(event.target_location)
	var source: CombatEntity = state.actors[event.actor_idx]
	var power = ability.power(source.stats)
	if target != null:
		match ability.effect.effect_type:
			SkillsCore.EffectType.Damage:
				return [deal_damage(source, target, power, event.timestamp, event.element)]
			SkillsCore.EffectType.StatBuff:
				state.resolve_stat_buff(target.entity_index, ability.effect.mod_stat, power)
	return []

static func get_event_source(state: EncounterState, event: EncounterEvent) -> CombatEntity:
	return state.actors[event.actor_idx]

static func get_event_target(state: EncounterState, event: EncounterEvent) -> CombatEntity:
	return state.actors[event.target_idx]





class FireRandomAbilityPlaceHolder:
	var timestamp: int
	var source: CombatEntity
	var ability: Ability
	func _init(_timestamp, _source, _ability):
		timestamp = _timestamp
		source = _source
		ability = _ability

static func trigger_reaction(timestamp: int, state: EncounterState, event: EncounterEvent, reactor: CombatEntity, reaction: Ability) -> Array:
	assert(reaction.activation.trigger == SkillsCore.Trigger.Automatic)
	# does the event type match the event filter?
	if reaction.activation.filter_event_type() != event.kind:
		return []
	# does the event source match the source filter?
	var source_location = state.actors[event.actor_idx].location
	if !actor_filter_match(state, reactor, source_location, reaction.activation.filter_event_source()):
		return []
	# does the event target match the target filter?
	if !actor_filter_match(state, reactor, event.target_location, reaction.activation.filter_event_target()):
		return []
	var target_loc
	var target: CombatEntity = null
	var target_location = event.target_location
	match reaction.activation.trigger_aim:
		SkillsCore.TriggerAim.EventSource: 
			target = state.actors[event.actor_idx]
			target_location = target.location
		SkillsCore.TriggerAim.Self:
			target = reactor
			target_location = target.location
		SkillsCore.TriggerAim.Random:
			pass
		SkillsCore.TriggerAim.EventTarget: if event.target_idx >= 0:
			target = state.actors[event.target_idx]
			target_location = target.location
	var e = EncEvent.reaction_event(timestamp, reactor, reaction, target, target_location)
	return [e]




static func get_ability_target(state: EncounterState, actor:CombatEntity, ability: Ability) -> Vector2:
	var targets = find_valid_targets(state, actor, ability)
	if targets.size() > 0:
		targets.shuffle()
		return targets[0]
	return Vector2.INF


#TODO: pass Actor instead of actor id
static func find_valid_targets(state: EncounterState, actor:CombatEntity, ability: Ability) -> Array:
	var locations = []
	var position = actor.location
	# locations should be all of the locations in ability.range such that
	# there is at least one valid target within the ability radius
	var r = ability.activation.ability_range
	var min_x = int(max(position.x-r, Constants.MAP_BOUNDARIES.position.x))
	var max_x = int(min(position.x+r, Constants.MAP_BOUNDARIES.size.x + Constants.MAP_BOUNDARIES.position.x))
	var min_y = int(max(position.y-r, Constants.MAP_BOUNDARIES.position.y))
	var max_y = int(min(position.y+r, Constants.MAP_BOUNDARIES.size.y + Constants.MAP_BOUNDARIES.position.y))
	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			if has_target(state, Vector2(x, y), ability.activation.radius, actor, ability.effect.targets):
				locations.append(Vector2(x, y))
	return locations

static func has_target(state: EncounterState, p: Vector2, radius: int, source: CombatEntity, filter: int) -> bool:
	var min_x = int(max(p.x-radius, Constants.MAP_BOUNDARIES.position.x))
	var max_x = int(min(p.x+radius, Constants.MAP_BOUNDARIES.size.x + Constants.MAP_BOUNDARIES.position.x))
	var min_y = int(max(p.y-radius, Constants.MAP_BOUNDARIES.position.y))
	var max_y = int(min(p.y+radius, Constants.MAP_BOUNDARIES.size.y + Constants.MAP_BOUNDARIES.position.y))
	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			if actor_filter_match(state, source, p, filter):
				return true
	return false

static func actor_filter_match(state: EncounterState, observer: CombatEntity, location: Vector2, filter: int) -> bool:
	var occupant = state.lookup_actor(location)
	if occupant == null:
		return Constants.matches_mask(SkillsCore.Target.Empty, filter)
	elif !occupant.is_alive():
		return false
	elif occupant == observer:
		return Constants.matches_mask(SkillsCore.Target.Self, filter)
	elif occupant.faction == observer.faction:
		return Constants.matches_mask(SkillsCore.Target.Allies, filter)
	elif occupant.faction != observer.faction:
		return Constants.matches_mask(SkillsCore.Target.Enemies, filter)
	return false
