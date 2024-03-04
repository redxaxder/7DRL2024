class_name EncounterCore

static func update(state: EncounterState, event: EncounterEvent) -> Array: # [ EncounterEvent ]
	assert(event.target_location != Vector2(-99999,-99999))
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
			state.resolve_attack(event.target_idx, get_damage_with_elements(state, event))
			if !target.is_alive():
				var killer = state.actors[event.actor_idx]
				result.append(EncEvent.death_event(event.timestamp, killer, target))
	for reactor in state.actors:
		for reaction in reactor.event_reactions():
			result.append_array(trigger_reaction(state, event, reactor, reaction))
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

static func trigger_reaction(state: EncounterState, event: EncounterEvent, reactor: CombatEntity, reaction: Ability) -> Array:
	return [] #TODO
#	var trigger_focus
#	match reaction.activation.trigger:
#		SkillsCore.Trigger.Action:
#			push_error("Inconceivable! Automatically triggering an activated ability?")
#			assert(false)
#		SkillsCore.Trigger.DamageTaken:
#			trigger_focus = event.
#	var does_it_trigger: bool = false
#	match reaction.activation.trigger_listen:
#		SkillsCore.Target.Self:
	
#static func trigger_damage_ability(state: EncounterState, event: EncounterEvent) -> EncounterEvent:
#	if event.damage > 0:
#		var responder: CombatEntity = state.actors[event.target_idx]
#		for ab in responder.abilities:
#			if ab.trigger_effect_kind == Ability.TriggerEffectKind.Damage && ab.trigger_target_kind == Ability.TargetKind.Self:
#				var atarget = state.get_ability_target(responder.entity_index, ab)
#				if atarget != Vector2.INF:
#					return use_ability(responder, atarget, ab, event.timestamp)
#	return null
