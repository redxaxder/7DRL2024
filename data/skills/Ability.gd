extends Resource

class_name Ability

var name: String = ""
var modifiers: Array = [] #Abilitymod
var activation: Activation
var effect: Effect

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
	var modified = base * (1 + sqrt(bonus / 100.0))
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

func describe_effect(stats: StatBlock) -> String:
	match effect.effect_type:
		SkillsCore.EffectType.Damage:
			return "Deal {0} damage".format([power(stats)])
		SkillsCore.EffectType.StatBuff:
			var increase = "Add"
			if effect.power < 0: increase = "Decrease"
			var buff = "buff" if effect.power > 0 else "debuff"
			
			return "Add {power} {stat} {buff}".format({
				"buff": buff,
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
	# text += "{trigger}\n".format(dict)
	if activation.trigger == SkillsCore.Trigger.Automatic:
		text += "{activation_text}\n".format(dict)
		
	text += "{effect_text}".format(dict)
	text += " to {target}.\n".format(dict)
	
	for m in modifiers:
		text += "{0} scales off {1}% of {2}.  \n".format([
			ModParam.keys()[m.modified_param],
			str(m.coefficient),
			Stat.Kind.keys()[m.modifier_stat]
		])
	text += "\n"
	
	if dict["range"] > 0:
		text += "Range: {range}\n".format(dict)
	if dict["radius"] > 0:
		text += "Radius: {radius}\n".format(dict)
	if dict["cooldown"] > 0:
		text += "Cooldown: {cooldown}\n".format(dict)
		
	return text


func describe_activation_condition() -> String:
	return "" #TODO
	
