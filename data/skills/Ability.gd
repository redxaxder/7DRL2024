extends Resource

class_name Ability

var name: String = ""
var modifiers: Array = [] #Abilitymod
var activation: Activation
var effect: Effect

#TODO (part C?): move all instance state out of here and into the owning actor
# this will let us alias the abilities when duplicating encounter states
var cooldown = 0

func _get_parameter_bonus(param: int, statblock: StatBlock) -> float:
	var bonus = 0
	for mod in modifiers:
		var m: AbilityMod = mod
		if m.modified_param != param: continue
		var stat_value = statblock.get_modified_stat(m.modifier_stat)
		bonus += m.coefficient * stat_value
	return bonus

func cooldown_time(stats: StatBlock) -> int:
	var bonus = _get_parameter_bonus(ModParam.CooldownTime, stats)
	# this scaling rule is one where every +100 bonus increases
	# the frequency of the skill by 100% of the base frequency
	# so at +100 bonus it can activate 2x as often, at +200, 3x as often, etc
	# these correspond to a 50% and 66% reduction in cooldown respectively
	# this is incidentally the same way league handles "haste,"
	# since they're solving the same problem
	var base = float(activation.cooldown_time)
	var modified = base * 100.0 / (100.0 + bonus)
	modified = max(1, int(modified)) # don't go below 1
	return modified

func power(stats: StatBlock) -> int:
	# power gets percentage bonuses
	var bonus = _get_parameter_bonus(ModParam.Power, stats)
	var base = float(effect.power)
	var modified = base * (100.0 + bonus)/100.0
	return int(modified)

func ability_range(stats: StatBlock) -> int:
	# range increases by 1 for every +100 bonus
	var bonus = _get_parameter_bonus(ModParam.AbilityRange, stats)
	var base = float(activation.ability_range)
	var modified = base + (bonus / 100.0)
	return int(modified)

func radius(stats: StatBlock) -> int:
	# radius increases the -area- of the effect proportionally to the bonus
	# so 100% bonus should correspond to double area.
	var bonus = _get_parameter_bonus(ModParam.Radius, stats)
	var base = float(activation.radius)
	var modified = base * sqrt(bonus / 100.0)
	return int(modified)

enum ModParam { Power, AbilityRange, CooldownTime, Radius } # TODO duration. do we have durations?
class AbilityMod extends Resource:
	var modifier_stat: int = Stat.Kind.Brains
	var coefficient: float = 0.1
	var modified_param: int = ModParam.Power
static func mod(stat: int, param:int , coeff: float) -> AbilityMod:
	var mod = AbilityMod.new()
	mod.modifier_stat = stat
	mod.modified_param = param
	mod.coefficient = coeff
	return mod

func on_cooldown() -> bool:
	return cooldown > 0
	
func cool(t: int):
	cooldown = max(0, cooldown - t)

func use():
	assert(cooldown == 0)
	cooldown = activation.cooldown_time

func describe_effect(stats: StatBlock) -> String:
	match effect.effect_type:
		SkillsCore.EffectType.Damage:
			return "deal {0} damage".format([power(stats)])
		SkillsCore.EffectType.StatBuff:
			var increase = "increase"
			if effect.power < 0: increase = "decrease"
			return "{increase} {stat} by {power}".format({
				"increase": increase,
				"stat": Stat.NAME[effect.mod_stat],
				"power": power(stats)
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
func generate_description(stats: StatBlock) -> String:
	var dict = {}
	dict["trigger"] = ["Action","Reaction"][activation.trigger]
	dict["range"] = ability_range(stats)
	dict["radius"] = radius(stats)
	dict["target"] = describe_target(effect.targets)
	dict["activation_text"] = describe_activation_condition()
	dict["effect_text"] = describe_effect(stats)
	dict["cooldown"] = cooldown_time(stats)
#	prints("hp", stats.max_hp())
	var text = ""
	text += "{trigger}\n".format(dict)
	text += "range: {range}\n".format(dict)
	text += "radius: {radius}\n".format(dict)
	text += "affects: {target}\n".format(dict)
	if activation.trigger == SkillsCore.Trigger.Automatic:
		text += "{activation_text}\n".format(dict)
	text += "effect: {effect_text}\n".format(dict)
	return text


func describe_activation_condition() -> String:
	return "" #TODO
	
