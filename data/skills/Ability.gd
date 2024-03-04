extends Resource

class_name Ability

var name: String = ""
var activation: Activation
var effect: Effect

var cooldown = 0

func on_cooldown() -> bool:
	return cooldown > 0
	
func cool(t: int):
	cooldown = max(0, cooldown - t)

func use():
	assert(cooldown == 0)
	cooldown = activation.cooldown_time

#TODO: fix descriptions
func generate_description() -> String:
	return ""
#	var abil_dict: Dictionary = {}
#	var key = "trigger_target"
#	match activation.trigger_target:
#		SkillsCore.TargetKind.Allies:
#			abil_dict[key] = "an ally"
#		SkillsCore.TargetKind.Any:
#			abil_dict[key] = "any creature"
#		TargetKind.Enemies:
#			abil_dict[key] = "an enemy"
#		TargetKind.Self:
#			abil_dict[key] = "you"
#	key = "trigger"
#	match trigger_effect_kind:
#		TriggerEffectKind.Activated:
#			match trigger_target_kind:
#				TargetKind.Self:
#					abil_dict[key] = "activate this"
#				_:
#					abil_dict[key] = "wants to"
#		TriggerEffectKind.Damage:
#			match trigger_effect_kind:
#				TargetKind.Self:
#					abil_dict[key] = "sustain damage"
#				_:
#					abil_dict[key] = "takes damage"
#	key = "ability_effect"
#	match effect_kind:
#		AbilityEffectKind.Buff:
#			match buff_kind:
#				BuffKind.Stat:
#					var increase = "increase"
#					if power < 0: increase = "decrease"
#					var target = "your"
#					if effect_target_kind != TargetKind.Self:
#						target = "target"
#					abil_dict[key] = "{increase} {target} {stat}".format(
#						{"increase": increase, "target": target, "stat": Stat.NAME[buff_stat]})
#		AbilityEffectKind.Damage:
#			abil_dict[key] = "damage"
#	key = "ability_target"
#	if effect_kind != AbilityEffectKind.Buff: #buff abilities handled above
#		match effect_target_kind:
#			TargetKind.Allies:
#				abil_dict[key] = "a buddy"
#			TargetKind.Any:
#				abil_dict[key] = "anything that moves"
#			TargetKind.Enemies:
#				abil_dict[key] = "a vile foe"
#			TargetKind.Self:
#				abil_dict[key] = "yourself"
#	else:
#		abil_dict[key] = ""
#	key = "r"
#	if ability_range > 0 and effect_target_kind != TargetKind.Self:
#		abil_dict[key] = " in range {0} ".format([ability_range])
#	else:
#		abil_dict[key] = ""
#	abil_dict["pow"] = power
#	abil_dict["c"] = activation.cooldown_time
#	var description = "When {trigger_target} {trigger_effect}, {ability_effect} {ability_target}{r}by {pow}. Cooldown {c}.".format(abil_dict)
#	return description
