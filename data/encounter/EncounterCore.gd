class_name EncounterCore

static func update(state: EncounterState, event: EncounterEvent) -> Array: # [ EncounterEvent ]
	assert(event.target_location != Vector2(-99999,-99999))
	assert(event.actor_idx >= 0)
	var result = []

	match event.kind:
		EncounterEvent.Kind.Move:
			if state.lookup_actor(event.target_location) == null:
				state.set_location(event.actor_idx, event.target_location)
		EncounterEvent.Kind.Attack:
			var source = state.actors[event.actor_idx]
			var target = state.actors[event.target_idx]
			result.append(deal_damage(source, target, event.damage, event.timestamp, event.elements))
		EncounterEvent.Kind.Death:
			state.remove_actor(event.target_idx)
		EncounterEvent.Kind.AbilityActivation:
			result.append_array(handle_ability_activation(state, event))
		EncounterEvent.Kind.Damage:
			var target = state.actors[event.target_idx]
# warning-ignore:narrowing_conversion
			state.resolve_attack(event.target_idx, get_damage_with_elements(state, event))
			if !target.is_alive():
				var killer = state.actors[event.actor_idx]
				result.append(EncEvent.death_event(event.timestamp, killer, target))
	for reactor in state.actors:
		for reaction in reactor.event_reactions():
			if reaction.on_cooldown(): continue
			result.append_array(trigger_reaction(event.timestamp, state, event, reactor, reaction))
	return result

static func use_ability(actor: CombatEntity, target: Vector2, ability: Ability, timestamp: int) -> Array: # [ EncounterEvent ]
	if ability.on_cooldown():
		return []
	ability.use()
	return [EncEvent.ability_event(timestamp, actor, ability, target, ability.effect.elements)]
	
static func deal_damage(source: CombatEntity, target: CombatEntity, damage: int, timestamp: int, elements: Array) -> EncounterEvent:
	return EncEvent.damage_event(timestamp, source, target, damage, elements)

static func get_damage_with_elements(state: EncounterState, event: EncounterEvent) -> float:
	assert(event.kind == EncounterEvent.Kind.Damage)
	var damage: float = float(event.damage)
	var target = state.actors[event.target_idx]
	for e in event.elements:
		damage *= target.defense_against(e)
	return damage
	
static func handle_ability_activation(state: EncounterState, event: EncounterEvent) -> Array: # [ EncounterEvent ]
	var ability = event.ability #TODO: handle AOEs
	var target = state.lookup_actor(event.target_location)
	var source = state.actors[event.actor_idx]
	if target != null:
		match ability.effect.effect_type:
			SkillsCore.EffectType.Damage:
				return [deal_damage(source, target, ability.effect.power, event.timestamp, event.elements)]
			SkillsCore.EffectType.StatBuff:
				state.resolve_stat_buff(target.entity_index, ability.effect.mod_stat, ability.effect.power)
	return []

static func get_event_source(state: EncounterState, event: EncounterEvent) -> CombatEntity:
	return state.actors[event.actor_idx]

static func get_event_target(state: EncounterState, event: EncounterEvent) -> CombatEntity:
	return state.actors[event.target_idx]



static func actor_filter_match(state: EncounterState, observer: CombatEntity, location: Vector2, filter: int) -> bool:
	var occupant = state.lookup_actor(location)
	if occupant == null:
		return Constants.matches_mask(SkillsCore.Target.Empty, filter)
	elif occupant == observer:
		return Constants.matches_mask(SkillsCore.Target.Self, filter)
	elif occupant.faction == observer.faction:
		return Constants.matches_mask(SkillsCore.Target.Allies, filter)
	elif occupant.faction != observer.faction:
		return Constants.matches_mask(SkillsCore.Target.Enemies, filter)
	return false


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
	if reaction.activation.filter_event_type != event.kind:
		return []
	# does the event source match the source filter?
	var source_location = state.actors[event.actor_idx].location
	if !actor_filter_match(state, reactor, source_location, reaction.activation.filter_event_source):
		return []
	# does the event target match the target filter?
	if !actor_filter_match(state, reactor, event.target_location, reaction.activation.filter_event_target):
		return []
	var target_loc
	match reaction.activation.trigger_aim:
		SkillsCore.TriggerAim.EventSource: 
			target_loc = source_location
		SkillsCore.TriggerAim.EventTarget:
			target_loc = event.target_location
		SkillsCore.TriggerAim.Random: 
			return [FireRandomAbilityPlaceHolder.new(timestamp, reactor, reaction)]
		SkillsCore.TriggerAim.Self:
			target_loc = reactor.location
	var step = (target_loc - reactor.location).abs()
	if max(step.x,step.y) > reaction.activation.ability_range:
		return []
	if !actor_filter_match(state, reactor, target_loc, reaction.effect.targets):
		return []
	return use_ability(reactor, target_loc, reaction, timestamp)




static func get_ability_target(state: EncounterState, actor_id: int, ability: Ability) -> Vector2:
	var targets = find_valid_targets(state, actor_id, ability)
	if targets.size() > 0:
		targets.shuffle()
		return targets[0]
	return Vector2.INF


#TODO: pass Actor instead of actor id
static func find_valid_targets(state: EncounterState, actor_id: int, ability: Ability) -> Array:
	var locations = []
	var can_target_empty = Constants.matches_mask(SkillsCore.Target.Empty, ability.effect.targets)
	if Constants.matches_mask(SkillsCore.Target.Self, ability.effect.targets):
		locations.append(state.actors[actor_id].location)
	var faction_mask: int = 0
	if Constants.matches_mask(SkillsCore.Target.Enemies, ability.effect.targets):
		faction_mask = faction_mask | Constants.negate_faction(state.actors[actor_id].faction)
	if Constants.matches_mask(SkillsCore.Target.Allies, ability.effect.targets):
		faction_mask = faction_mask | state.actors[actor_id].faction
	var position = state.actors[actor_id].location
	# locations should be all of the locations in ability.range such that
	# there is at least one valid target within the ability radius
	var r = ability.activation.ability_range
	var min_x = int(max(position.x-r, Constants.MAP_BOUNDARIES.position.x))
	var max_x = int(min(position.x+r, Constants.MAP_BOUNDARIES.size.x + Constants.MAP_BOUNDARIES.position.x))
	var min_y = int(max(position.y-r, Constants.MAP_BOUNDARIES.position.y))
	var max_y = int(min(position.y+r, Constants.MAP_BOUNDARIES.size.y + Constants.MAP_BOUNDARIES.position.y))
	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			if has_location_in_range(state, Vector2(x, y), ability.activation.radius, faction_mask, can_target_empty):
				locations.append(Vector2(x, y))
	return locations


static func has_location_in_range(state: EncounterState, p: Vector2, radius: int, faction_mask: int, can_target_empty: bool):
	var min_x = int(max(p.x-radius, Constants.MAP_BOUNDARIES.position.x))
	var max_x = int(min(p.x+radius, Constants.MAP_BOUNDARIES.size.x + Constants.MAP_BOUNDARIES.position.x))
	var min_y = int(max(p.y-radius, Constants.MAP_BOUNDARIES.position.y))
	var max_y = int(min(p.y+radius, Constants.MAP_BOUNDARIES.size.y + Constants.MAP_BOUNDARIES.position.y))
	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			var effect_location = Vector2(x,y)
			var effect_target = state.lookup_actor(effect_location)
			if effect_target == null:
				if can_target_empty: return true
				else: continue
			if Constants.matches_mask(effect_target.faction, faction_mask):
				return true
	return false
