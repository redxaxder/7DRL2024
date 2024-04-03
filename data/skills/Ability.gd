extends Resource

class_name Ability

var name: String = ""
var modifiers: Array = [] #Abilitymod
var activation: Activation
var effect: Effect

const alias_ok = true

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
	
# returns the power modified by the elemental power multiplier
func power_with_element_power(stats: StatBlock, element: int) -> int:
	var base_power = power(stats)
	var multiplier = stats.get_elemental_power_multiplier(element)
	return int(base_power * multiplier)

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
	
func get_color():
	if effect:
		if effect.element == Elements.Kind.Physical:
			return Color("#e7ad47")
		elif effect.element == Elements.Kind.Poison:
			return Color("#24ff7a")
		elif effect.element == Elements.Kind.Fire:
			return Color("#ff2503")
		elif effect.element == Elements.Kind.Ice:
			return Color("#3eb7ff")
	return Color.wheat
	
func get_modifier_scaling_desc(modified_param : int ):
	for m in modifiers:
		if m.modified_param == modified_param:
			return "{0}".format([
				# str(m.coefficient * 100),
				Stat.NAME[m.modifier_stat]
			])

const ELEMENT_NAME = ["physical", "fire", "ice", "poison"]
func describe_effect(stats: StatBlock) -> String:
	var scaled_power = power(stats)
	var base_power = effect.power
	var scaled_string = ""
	var modifier_scaling = get_modifier_scaling_desc(ModParam.Power)
	scaled_string = " ([color=#3affa9]{0} {1} {2}{3} scaling[/color])".format([
		effect.power,
		"+" if effect.power > 0 else "-",
		"{0}/".format([modifier_scaling]) if modifier_scaling else "",
		Stat.NAME[Elements.ATTACK[effect.element]]
	])
				
	match effect.effect_type:
		SkillsCore.EffectType.Damage:
			return "deal {0}{1} {2} damage".format([
				power_with_element_power(stats, effect.element),
				scaled_string,
				ELEMENT_NAME[effect.element]
			])
		SkillsCore.EffectType.StatBuff:
			var plus = "+" if effect.power > 0 else ""
			
			var power_string = "{0}{1}".format([
				power_with_element_power(stats, effect.element),
				scaled_string
			])
			
			return "apply {plus}{power} {stat}".format({
				"stat": Stat.NAME[effect.mod_stat],
				"power": power_string,
				"plus": plus
			})
	assert(false, "missing effect description")
	return ""
			

			
			
func describe_target(target_filter:int, radius: float, trigger_aim : int, trigger: int) -> String:
	if target_filter == SkillsCore.Target.Self:
		return "yourself"
		
	if trigger == SkillsCore.Trigger.Action:
		match target_filter:
			SkillsCore.Target.Allies: return "allies"
			SkillsCore.Target.Enemies: return "enemies"
			SkillsCore.TargetAny: return "all targets"
	
	var who_affected = ""
	match target_filter:
		SkillsCore.Target.Allies: who_affected = "allies"
		SkillsCore.Target.Enemies: who_affected = "enemies"
		SkillsCore.TargetAny: who_affected = "targets"
	
	var where_effect = ""
	var is_radius = ""
	
	if radius > 0:
		if(trigger_aim == SkillsCore.TriggerAim.Self):
			match target_filter:
				SkillsCore.Target.Allies: return "nearby allies"
				SkillsCore.Target.Enemies: return "nearby enemies"
				SkillsCore.TargetAny: return "nearby units"
		if(trigger_aim == SkillsCore.TriggerAim.EventSource ||
		trigger_aim == SkillsCore.TriggerAim.EventTarget):
			match target_filter:
				SkillsCore.Target.Allies: return "nearby allies"
				SkillsCore.Target.Enemies: return "nearby enemies"
				SkillsCore.TargetAny: return "nearby units"
		if(trigger_aim == SkillsCore.TriggerAim.Random):
			match target_filter:
				SkillsCore.Target.Allies: return "random allies"
				SkillsCore.Target.Enemies: return "random enemies"
				SkillsCore.TargetAny: return "random units"
	else: #radius 0
		if(trigger_aim == SkillsCore.TriggerAim.Self):
			return "yourself";
		if(trigger_aim == SkillsCore.TriggerAim.EventSource ||
		trigger_aim == SkillsCore.TriggerAim.EventTarget):
			return "them"
		if(trigger_aim == SkillsCore.TriggerAim.Random):
			match target_filter:
				SkillsCore.Target.Allies: return "an ally"
				SkillsCore.Target.Enemies: return "an enemy"
				SkillsCore.TargetAny: return "a unit"
	assert(false, "unhandled target")
	return ""
	
func describe_radius(stats: StatBlock):
	var scaled_string = ""
	var modifier_scaling = get_modifier_scaling_desc(ModParam.Radius)
	if modifier_scaling: # always remind about scaling
		scaled_string = " ([color=#3affa9]{0} + {1} scaling[/color])".format([
			activation.radius,
			modifier_scaling,
		])
		
	return "Radius: {0}{1}\n".format([
		radius(stats),
		scaled_string
	])
	
func describe_cooldown(stats: StatBlock):
	var scaled_string = ""
	var modifier_scaling = get_modifier_scaling_desc(ModParam.CooldownTime)
	if modifier_scaling: # always remind about scaling
		scaled_string = " ([color=#3affa9]{0} - {1} scaling[/color])".format([
			activation.cooldown_time,
			modifier_scaling,
		])
		
	return "Cooldown: {0}{1}\n".format([
		cooldown_time(stats),
		scaled_string
	])
	
func describe_range(stats: StatBlock):
	var scaled_string = ""
	var modifier_scaling = get_modifier_scaling_desc(ModParam.AbilityRange)
	if modifier_scaling: # always remind about scaling
		scaled_string = " ([color=#3affa9]{0} + {1} scaling[/color])".format([
			activation.ability_range,
			modifier_scaling,
		])
		
	return "Range: {0}{1}\n".format([
		ability_range(stats),
		scaled_string
	])
	

func generate_description(stats: StatBlock) -> String:
	var dict = {}
	dict["trigger"] = ["Action","Reaction"][activation.trigger]
	
	dict["range"] = describe_range(stats)
	dict["radius"] = describe_radius(stats)
	dict["target"] = describe_target(effect.targets, radius(stats), activation.trigger_aim, activation.trigger)
	dict["activation_text"] = describe_activation_condition()
	dict["effect_text"] = describe_effect(stats)
	dict["cooldown"] = describe_cooldown(stats)
#	prints("hp", stats.max_hp())
	var text = ""
	# text += "{trigger}\n".format(dict)
	if activation.trigger == SkillsCore.Trigger.Automatic:
		text += "{activation_text}, ".format(dict)
	else:
		text += "As an action, "
		
	text += "{effect_text}".format(dict)
		
	text += " to {target}.\n".format(dict)
	
#	for m in modifiers:
#		text += "{0} scales off {1}% of {2}.  \n".format([
#			ModParam.keys()[m.modified_param],
#			str(m.coefficient),
#			Stat.Kind.keys()[m.modifier_stat]
#		])
	text += "\n"
	
	if dict.range != "" && ability_range(stats) > 0:
		text += dict.range
	if dict.radius != "" && radius(stats) > 0:
		text += dict.radius
	if dict.cooldown != "":
		text += dict.cooldown
		
		
	# DEBUG
	var debug = Constants.debug_mode
	if debug:
		text += "\n"
		text += "\n"
		text += "DEBUG:\n"
		text += "Trigger aim: {0}\n".format([
			SkillsCore.TriggerAim.keys()[activation.trigger_aim]
		])
		
	return text


func describe_filter_actor(target_filter:int) -> String:
	match target_filter:
		SkillsCore.Target.Self: return "you"
		SkillsCore.Target.Allies: return "an ally"
		SkillsCore.Target.Enemies: return "an enemy"
		SkillsCore.TargetAny: return "anyone"
	assert(false, "unhandled target")
	return ""

func describe_filter_actor_possessive(target_filter:int) -> String:
	match target_filter:
		SkillsCore.Target.Self: return "your"
		SkillsCore.Target.Allies: return "an ally's"
		SkillsCore.Target.Enemies: return "an enemy's"
		SkillsCore.TargetAny: return "anyone's"
	assert(false, "unhandled target")
	return ""

func describe_activation_condition() -> String:
	var filter_actor_desc = describe_filter_actor(activation.filter_actor)
	var filter_actor_desc_ = describe_filter_actor(activation.filter_actor)
	var optional_s = "" if filter_actor_desc == "you" else "s"
	if activation.filter == Activation.Filter.DamageDealt:
		return "Whenever {0} deal{1} damage".format([
			filter_actor_desc,
			optional_s
		])
	elif activation.filter == Activation.Filter.DamageReceived:
		return "Whenever damage is dealt to {0}".format([
			describe_filter_actor(activation.filter_actor)
		])
	elif activation.filter == Activation.Filter.Death:
		return "Whenever {0} die{1}".format([
			filter_actor_desc,
			optional_s
		])
	elif activation.filter == Activation.Filter.Movement:
		return "Whenever {0} move{1}".format([
			filter_actor_desc,
			optional_s
		])
	elif activation.filter == Activation.Filter.Start:
		return "At the start of an encounter"
	elif activation.filter == Activation.Filter.Bloodied:
		return "Whenever {0} HP drops below 50%".format([
			describe_filter_actor_possessive(activation.filter_actor)
		])
	elif activation.filter == Activation.Filter.Miss:
		return "Whenever {0} attack misses".format([
			describe_filter_actor_possessive(activation.filter_actor)
		])
	elif activation.filter == Activation.Filter.Dodge:
		return "Whenever {0} dodge{1} an attack".format([
			filter_actor_desc,
			optional_s
		])
	elif activation.filter == Activation.Filter.Attack:
		return "Whenever {0} land{1} an attack".format([
			filter_actor_desc,
			optional_s
		])
	assert(false, "unhandled target")
	return ""

