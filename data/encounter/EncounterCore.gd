class_name EncounterCore

static func update(state: EncounterState, event: EncounterEvent) -> Array: # [ EncounterEvent ]
	var result = []
	for reactor in state.actors:
		for reaction in reactor.event_reactions():
			if !reactor.can_use_ability(reaction, event.timestamp): continue
			result.append_array(trigger_reaction(event.timestamp, state, event, reactor, reaction))
	match event.kind:
		EncounterEventKind.Kind.Move:
			if state.lookup_actor(event.target_location) == null:
				state.set_location(event.actor_idx, event.target_location)
		EncounterEventKind.Kind.Attack:
			assert(event.target_idx >= 0)
			var source = state.actors[event.actor_idx]
			var target = state.actors[event.target_idx]
			if event.damage > 0:
				result.append(EncEvent.damage_event(event.timestamp, source, target, event.damage, event.is_crit, event.element))
		EncounterEventKind.Kind.Death:
			assert(event.target_idx >= 0)
			state.remove_actor(event.target_idx)
		EncounterEventKind.Kind.AbilityActivation:
			result.append_array(handle_ability_activation(state, event))
		EncounterEventKind.Kind.Damage: 
			assert(event.target_idx >= 0)
			var source = state.actors[event.actor_idx]
			if event.damage > 0:
				var target = state.actors[event.target_idx]
				var target_was_bloodied = (float(target.cur_hp) / float(target.stats.max_hp())) < 0.25
				state.resolve_attack(event.target_idx, event.damage)
				var target_is_bloodied = (float(target.cur_hp) / float(target.stats.max_hp())) < 0.25
				if !target.is_alive():
					result.append(EncEvent.death_event(event.timestamp, source, target))
				elif target_is_bloodied and !target_was_bloodied:
					result.append(EncEvent.bloodied_event(event.timestamp,source, target))
		EncounterEventKind.Kind.StatChange:
			assert(event.target_idx >= 0)
			var target = state.actors[event.target_idx]
			state.resolve_stat_buff(event.target_idx, event.stat, event.damage)
			if !target.is_alive():
				var killer = state.actors[event.actor_idx]
				result.append(EncEvent.death_event(event.timestamp, killer, target))
# other events do not affect encounter state directly. other things can listen for them
		_: pass

	return result

static func use_ability(actor: CombatEntity, target: Vector2, ability: Ability, timestamp: float) -> Array: # [ EncounterEvent ]
	if !actor.can_use_ability(ability, timestamp): return []
	return [EncEvent.ability_event(timestamp, actor, ability, target, ability.effect.element)]
	
static func handle_ability_activation(state: EncounterState, event: EncounterEvent) -> Array: # [ EncounterEvent ]
	var ability = event.ability
	var source: CombatEntity = state.actors[event.actor_idx]
	var power = ability.power(source.stats)

	var target_location = event.target_location
	if event.target_idx >= 0: # if we're aiming at an actor, track them as they move
		target_location = state.actors[event.target_idx].location

	source.mark_ability_use(ability, event.timestamp)
	var targets = affected_targets(state, target_location, source, ability)
	if targets.size() == 0: return [] # oops, missed. i dont think this can actually happen.
	
	var is_crit = false
	var events = []
	for location in targets:
		var target = state.lookup_actor(location)
		match ability.effect.effect_type:
			SkillsCore.EffectType.Damage:
				events.append(EncEvent.damage_event(event.timestamp, source, target, power, is_crit, event.element))
			SkillsCore.EffectType.StatBuff:
				events.append(EncEvent.stat_change_event(event.timestamp, source, target, ability.effect.mod_stat, power))
	return events

static func trigger_reaction(timestamp: float, state: EncounterState, event: EncounterEvent, reactor: CombatEntity, reaction: Ability) -> Array:
	assert(reaction.activation.trigger == SkillsCore.Trigger.Automatic)
	if event.kind == EncounterEventKind.Kind.Death:
		pass
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

# answers the question:
# for which spaces in range will firing the ability at that space affect anyone?
static func find_valid_targets(state: EncounterState, actor:CombatEntity, ability: Ability) -> Array:
	var locations = []
	var position = actor.location
	# locations should be all of the locations in ability.range such that
	# there is at least one valid target within the ability radius
	var r = ability.ability_range(actor.stats)
	var radius = ability.radius(actor.stats)
	var min_x = int(max(position.x-r, Constants.MAP_BOUNDARIES.position.x))
	var max_x = int(min(position.x+r, Constants.MAP_BOUNDARIES.size.x + Constants.MAP_BOUNDARIES.position.x))
	var min_y = int(max(position.y-r, Constants.MAP_BOUNDARIES.position.y))
	var max_y = int(min(position.y+r, Constants.MAP_BOUNDARIES.size.y + Constants.MAP_BOUNDARIES.position.y))
	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			if has_target(state, Vector2(x, y), radius, actor, ability.effect.targets):
				locations.append(Vector2(x, y))
	return locations

# answers the question: given a target space, who gets affected by this?
static func affected_targets(state: EncounterState, p: Vector2, source: CombatEntity, ability: Ability) -> Array:
	var targets = []
	var radius = ability.radius(source.stats)
	var filter = ability.effect.targets
	var min_x = int(max(p.x-radius, Constants.MAP_BOUNDARIES.position.x))
	var max_x = int(min(p.x+radius, Constants.MAP_BOUNDARIES.size.x + Constants.MAP_BOUNDARIES.position.x))
	var min_y = int(max(p.y-radius, Constants.MAP_BOUNDARIES.position.y))
	var max_y = int(min(p.y+radius, Constants.MAP_BOUNDARIES.size.y + Constants.MAP_BOUNDARIES.position.y))
	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			if actor_filter_match(state, source, Vector2(x,y), filter):
				targets.append(Vector2(x,y))
	return targets
	
# answers the question: if i fire this ability at this space, will it affect anyone?
static func has_target(state: EncounterState, p: Vector2, radius: int, source: CombatEntity, filter: int) -> bool:
	var min_x = int(max(p.x-radius, Constants.MAP_BOUNDARIES.position.x))
	var max_x = int(min(p.x+radius, Constants.MAP_BOUNDARIES.size.x + Constants.MAP_BOUNDARIES.position.x))
	var min_y = int(max(p.y-radius, Constants.MAP_BOUNDARIES.position.y))
	var max_y = int(min(p.y+radius, Constants.MAP_BOUNDARIES.size.y + Constants.MAP_BOUNDARIES.position.y))
	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			if actor_filter_match(state, source, Vector2(x,y), filter):
				return true
	return false

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
