class_name EncounterCore


#TODO: return an array
static func update(state: EncounterState, event: EncounterEvent) -> EncounterEvent:
	match event.kind:
		EncounterEvent.Kind.Move:
			if state.lookup_actor(event.target_location) != null:
				return null
			state.set_location(event.actor_idx, event.target_location)
		EncounterEvent.Kind.Attack:
			var target = state.actors[event.target_idx]
			return deal_damage(target, event.damage, event.timestamp, event.elements)
		EncounterEvent.Kind.Death:
			state.remove_actor(event.actor_idx)
		EncounterEvent.Kind.AbilityActivation:
			return handle_ability_activation(state, event)
		EncounterEvent.Kind.Damage:
			var target = state.actors[event.target_idx]
			state.resolve_attack(event.target_idx, get_damage_with_elements(state, event))
			if !target.is_alive():
				return EncEvent.death_event(event.timestamp, target)
	return null

static func use_ability(actor: CombatEntity, target: Vector2, ability: Ability, timestamp: int) -> EncounterEvent:
	if ability.on_cooldown():
		return null
	ability.use()
	return EncEvent.ability_event(timestamp, actor, ability, target, ability.effect.elements)
	
static func deal_damage(target: CombatEntity, damage: int, timestamp: int, elements: Array) -> EncounterEvent:
	return EncEvent.damage_event(timestamp, target, damage, elements)

static func get_damage_with_elements(state: EncounterState, event: EncounterEvent) -> float:
	assert(event.kind == EncounterEvent.Kind.Damage)
	var damage: float = float(event.damage)
	var target = state.actors[event.target_idx]
	for e in event.elements:
		damage *= target.defense_against(e)
	return damage
	
static func handle_ability_activation(state: EncounterState, event: EncounterEvent) -> EncounterEvent:
	var ability = event.ability #TODO: handle AOEs
	var target = state.lookup_actor(event.target_location)
	if target != null:
		match ability.effect.effect_type:
			SkillsCore.EffectType.Damage:
				return deal_damage(target, ability.effect.power, event.timestamp, event.elements)
			SkillsCore.EffectType.StatBuff:
				state.resolve_stat_buff(target.entity_index, ability.effect.mod_stat, ability.effect.power)
	return null

#TODO: bring back triggers
#static func trigger_damage_ability(state: EncounterState, event: EncounterEvent) -> EncounterEvent:
#	if event.damage > 0:
#		var responder: CombatEntity = state.actors[event.target_idx]
#		for ab in responder.abilities:
#			if ab.trigger_effect_kind == Ability.TriggerEffectKind.Damage && ab.trigger_target_kind == Ability.TargetKind.Self:
#				var atarget = state.get_ability_target(responder.entity_index, ab)
#				if atarget != Vector2.INF:
#					return use_ability(responder, atarget, ab, event.timestamp)
#	return null
