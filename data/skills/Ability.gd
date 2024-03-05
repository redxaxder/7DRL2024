extends Resource

class_name Ability

var name: String = ""
var activation: Activation
var effect: Effect

#TODO (part C?): move all instance state out of here and into the owning actor
# this will let us alias the abilities when duplicating encounter states
var cooldown = 0

func on_cooldown() -> bool:
	return cooldown > 0
	
func cool(t: int):
	cooldown = max(0, cooldown - t)

func use():
	assert(cooldown == 0)
	cooldown = activation.cooldown_time

func describe_effect() -> String:
	match effect.effect_type:
		SkillsCore.EffectType.Damage:
			return "deal {0} damage".format([effect.power])
		SkillsCore.EffectType.StatBuff:
			var increase = "increase"
			if effect.power < 0: increase = "decrease"
			return "{increase} {stat} by {power}".format({
				"increase": increase,
				"stat": Stat.NAME[effect.mod_stat],
				"power": effect.power
			})
	assert(false, "missing effect description")
	return ""
			
func describe_target(target_filter:int) -> String:
	match target_filter:
		SkillsCore.Target.Self: return "self"
		SkillsCore.Target.Allies: return "ally"
		SkillsCore.Target.Enemies: return "enemy"
		SkillsCore.TargetAny: return "any"
	assert(false, "unhandled target")
	return ""

#TODO: fix descriptions
func generate_description() -> String:
	var dict = {}
	dict["trigger"] = ["Action","Reaction"][activation.trigger]
	dict["range"] = activation.ability_range
	dict["radius"] = activation.radius
	dict["target"] = describe_target(effect.targets)
	dict["activation_text"] = describe_activation_condition()
	dict["effect_text"] = describe_effect()
	var text = ""
	text += "{trigger}\n".format(dict)
	text += "range: {range}\n".format(dict)
	text += "radius: {radius}\n".format(dict)
	text += "target: {target}\n".format(dict)
	if activation.trigger == SkillsCore.Trigger.Automatic:
		text += "{activation_text}\n".format(dict)
	text += "effect: {effect_text}\n".format(dict)
	return text


func describe_activation_condition() -> String:
	return ""
	
