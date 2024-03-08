extends Resource

class_name SkillTree

export var skills: Array = [] # 2D Array of Skill
export var name: String

export var skillsPerRow: int = 5
export var numRows: int = 3

var unlocks: Dictionary

var skill_names = [
	"Aphotic Reach",
	"Draconic Assailment",
	"Modest Beheading",
	"Inscrutable Strike",
	"Disgrace of the World",
	"Dementia against Greed",
	"Slaughter against Strength",
	"Miraculous Luck",
	"Hangman's Starve",
	"Monster's Edge",
	"Serpent's Stone",
	"Devil's Tomorrow",
	"Burly Assault",
	"Poisonous Shout",
	"Mastadon's Burly Glory",
]

func addSkill(skillName: String, i: int, _j:int) -> Skill:
	var skill = Skill.new()
	skill.name = skillName
	skills[i].append(skill)
	return skill
	
func append_skill(skill: Skill, row: int):
	skills[row].append(skill)
	
func unlock(skill: Skill):
	unlocks[skill] = true

static func random_bonus_skill(skill_name: String, rng_seed: int) -> Skill:
	var skill = Skill.new()
	skill.kind = Skill.Kind.Bonus
	skill.name = skill_name
	skill.bonuses = Skill.random_bonus(rng_seed)
	return skill

static func create_ability_skill(ability: Ability) -> Skill:
	var skill = Skill.new()
	skill.name = ability.name
	skill.kind = Skill.Kind.Ability
	skill.ability = ability
	return skill

static func build_ability(d: Dictionary) -> Ability:
	var result = Ability.new()
	result.name = d.get("label", "unnamed")
	result.effect = Effect.new()
	result.effect.set_script(preload("res://data/skills/Effect.gd"))
	DataUtil.assign_from_dict(result.effect, d)
	result.activation = Activation.new()
	result.activation.set_script(preload("res://data/skills/Activation.gd"))
	DataUtil.assign_from_dict(result.activation, d)
	var allowed_keys = ["label"]
	for prop in result.effect.get_property_list():
		allowed_keys.append(prop["name"])
	for prop in result.activation.get_property_list():
		allowed_keys.append(prop["name"])
	for key in d.keys():
		var found = allowed_keys.find(key) >= 0
		assert(found, str("invalid key in build_ability: '", key,"'"))
	return result


var trigger = SkillsCore.Trigger.Action

# for automatic triggers: which events will trigger this?
var filter_event_type = -1
var filter_event_source = SkillsCore.TargetAny
var filter_event_target = SkillsCore.TargetAny

# for automatic triggers: where does the effect get applied
var trigger_aim = SkillsCore.TriggerAim.EventSource
func hand_rolled_skill_tree():
	name = "Jack of All Trades"
	skills = []
	for i in numRows:
		skills.append([])
	seed(1234)
# warning-ignore:unused_variable
#	var abil: Skill = create_ability_skill(build_ability({
#		"label": SkillName.generate_name(),
#		"trigger": SkillsCore.Trigger.Automatic,
#		"filter": Activation.Filter.DamageDealt,
#		"filter_actor": SkillsCore.TargetAny,
#		"trigger_aim": SkillsCore.TriggerAim.Self,
#		"effect_type": SkillsCore.EffectType.StatBuff,
#		"ability_range": 4,
#		"mod_stat": Stat.Kind.Health,
#		"power": 10,
#		"targets": SkillsCore.Target.Self,
#		}))
## warning-ignore:unused_variable
#	var my_cool_skill: Skill = create_ability_skill(build_ability({
#		"label": SkillName.generate_name(),
#		"trigger": SkillsCore.Trigger.Automatic,
#		"filter": Activation.Filter.DamageReceived,
#		"filter_actor": SkillsCore.Target.Self,
#		"trigger_aim": SkillsCore.TriggerAim.Self,
#		"effect_type": SkillsCore.EffectType.StatBuff,
#		"mod_stat": Stat.Kind.Damage,
#		"power": 1000,
#		"targets": SkillsCore.Target.Self
#	}))
#	var my_cool_death_ability: Ability = build_ability({
#		"label": SkillName.generate_name(),
#		"trigger": SkillsCore.Trigger.Automatic,
#		"filter": Activation.Filter.Death,
#		"filter_actor": SkillsCore.Target.Enemies,
#		"trigger_aim": SkillsCore.TriggerAim.Random,
#		"effect_type": SkillsCore.EffectType.StatBuff,
#		"mod_stat": Stat.Kind.Speed,
#		"ability_range": 0,
#		"power": -5,
#		"targets": SkillsCore.Target.Enemies,
#	})
#	my_cool_death_ability.modifiers = [
#		Ability.mod(Stat.Kind.Health, Ability.ModParam.AbilityRange, 100)
#	]
	
#	var aoe_test_ability: Ability = build_ability({
#		"label": SkillName.generate_name(),
#		"trigger": SkillsCore.Trigger.Action,
#		"effect_type": SkillsCore.EffectType.Damage,
#		"ability_range": 0,
#		"power": 1,
#		"radius": 1,
#		"cooldown_time": 1,
#		"targets": SkillsCore.Target.Enemies,
#	})
#	aoe_test_ability.modifiers = [
#		Ability.mod(Stat.Kind.Health, Ability.ModParam.Radius, 100)
#	]


#	append_skill(create_ability_skill(aoe_test_ability), 1)

	
	# ROW 0
	# *****
	append_and_create_ability({
		"element": Elements.Kind.Poison,
		"row": 0,
			# ***EFFECT***
		"effect_type":	SkillsCore.EffectType.Damage,
		"power":		10,
			# ***EFFECT AIM***
		"trigger_aim": 	SkillsCore.TriggerAim.Random,
		"ability_range":3,
		"radius":		2,
		"targets": 		SkillsCore.Target.Enemies,
			# ***TRIGGER***
		"trigger": 		SkillsCore.Trigger.Automatic,
		"filter": 		Activation.Filter.Death,
		"filter_actor": SkillsCore.Target.Enemies,
		"cooldown_time": 5,
		"modifiers": [Ability.mod(Stat.Kind.Guts, Ability.ModParam.AbilityRange, 5)]
	})
	
	append_skill(
		random_bonus_skill(SkillName.generate_name(), randi())
		, 0
		)
	
	append_and_create_ability({
		# "label": "Fiery Fire",
		"element": Elements.Kind.Fire,
		"row": 0,
			# ***EFFECT***
		"effect_type":	SkillsCore.EffectType.StatBuff,
		"mod_stat": 		Stat.Kind.Accuracy,
		"power":			10,
			# ***EFFECT AIM***
		"trigger_aim": 	SkillsCore.TriggerAim.Self,
		"ability_range":  0,
		"radius":			0,
		"targets": 		SkillsCore.Target.Self,
			# ***TRIGGER***
		"trigger": 		SkillsCore.Trigger.Automatic,
		"filter": 		Activation.Filter.Movement,
		"filter_actor": 	SkillsCore.Target.Self,
		"cooldown_time":	1,
		"modifiers": [Ability.mod(Stat.Kind.Brains, Ability.ModParam.Power, 1)]
	})
	
	append_skill(
		random_bonus_skill(SkillName.generate_name(), randi())
		, 0
		)
	
	# Deal 10 damage to an enemy in a 5 radius (4 cooldown)
	append_and_create_ability({
		"element": Elements.Kind.Ice,
		"trigger": SkillsCore.Trigger.Action,
		"effect_type": SkillsCore.EffectType.Damage,
		"ability_range": 0,
		"power": 10,
		"radius": 5,
		"cooldown_time": 30,
		"targets": SkillsCore.Target.Enemies,
		"modifiers": [
			Ability.mod(Stat.Kind.Crit, Ability.ModParam.Radius, 1)
		],
		"row": 0
	})
	
	
	# ROW 1
	# *****
	append_and_create_ability({
		"element": Elements.Kind.Physical,
		"row": 1,
			# ***EFFECT***
		"effect_type":	SkillsCore.EffectType.Damage,
		"power": 5,
			# ***EFFECT AIM***
		"trigger_aim": 	SkillsCore.TriggerAim.EventSource,
		"ability_range": 0,
		"radius": 0,
		"targets": 		SkillsCore.Target.Enemies,
			# ***TRIGGER***
		"trigger": 		SkillsCore.Trigger.Automatic,
		"filter": 		Activation.Filter.Attack,
		"filter_actor": 	SkillsCore.Target.Enemies,
		"cooldown_time":	1,
		"modifiers": [Ability.mod(Stat.Kind.Damage, Ability.ModParam.Power, 1)]
	})
	
	append_skill(
		random_bonus_skill(SkillName.generate_name(), randi()),
		1
		)
	
	append_and_create_ability({
		"element": Elements.Kind.Physical,
		"row": 1,
			# ***EFFECT***
		"effect_type":	SkillsCore.EffectType.Damage,
		"power": 3,
			# ***EFFECT AIM***
		"trigger_aim": 	SkillsCore.TriggerAim.Self,
		"ability_range": 0,
		"radius": 3,
		"targets": 		SkillsCore.Target.Enemies,
			# ***TRIGGER***
		"trigger": 		SkillsCore.Trigger.Automatic,
		"filter": 		Activation.Filter.Dodge,
		"filter_actor": 	SkillsCore.Target.Enemies,
		"cooldown_time":	20,
		"modifiers": [Ability.mod(Stat.Kind.Evasion, Ability.ModParam.CooldownTime, 2)]
	})
	
	append_skill(
		random_bonus_skill(SkillName.generate_name(), randi()),
		1
		)
	
	append_and_create_ability({
		"element": Elements.Kind.Physical,
		"row": 1,
			# ***EFFECT***
		"effect_type":	SkillsCore.EffectType.Damage,
		"power": 5,
			# ***EFFECT AIM***
		"trigger_aim": 	SkillsCore.TriggerAim.Random,
		"ability_range": 4,
		"radius": 0,
		"targets": 		SkillsCore.Target.Enemies,
			# ***TRIGGER***
		"trigger": 		SkillsCore.Trigger.Automatic,
		"filter": 		Activation.Filter.Miss,
		"filter_actor": 	SkillsCore.Target.Enemies,
		"cooldown_time":	10,
	})
	
	
	# ROW 2
	# *****
	
	append_and_create_ability({
		"element": Elements.Kind.Poison,
		"row": 2,
			# ***EFFECT***
		"effect_type":	SkillsCore.EffectType.Damage,
		"power": 25,
			# ***EFFECT AIM***
		"trigger_aim": 	SkillsCore.TriggerAim.Self,
		"ability_range": 0,
		"radius": 2,
		"targets": 		SkillsCore.Target.Enemies,
			# ***TRIGGER***
		"trigger": 		SkillsCore.Trigger.Automatic,
		"filter": 		Activation.Filter.Bloodied,
		"filter_actor": 	SkillsCore.Target.Self,
		"cooldown_time":	100,
	})
	
	append_skill(
		random_bonus_skill(SkillName.generate_name(), randi()),
		2
		)
	
	append_and_create_ability({
		"element": Elements.Kind.Poison,
		"row": 2,
			# ***EFFECT***
		"effect_type":	SkillsCore.EffectType.Damage,
		"power": 10,
			# ***EFFECT AIM***
		"trigger_aim": 	SkillsCore.TriggerAim.Self,
		"ability_range": 0,
		"radius": 6,
		"targets": 		SkillsCore.Target.Enemies,
			# ***TRIGGER***
		"trigger": 		SkillsCore.Trigger.Automatic,
		"filter": 		Activation.Filter.Start,
		"filter_actor": 	SkillsCore.Target.Self,
		"cooldown_time":	0,
	})
	
	# todo: don't display cooldown time for start
	
	append_skill(
		random_bonus_skill(SkillName.generate_name(), randi()),
		2
		)
	
	append_and_create_ability({
		"element": Elements.Kind.Fire,
		"row": 2,
			# ***EFFECT***
		"effect_type":	SkillsCore.EffectType.StatBuff,
		"mod_stat": 		Stat.Kind.Health,
		"power":			10,
			# ***EFFECT AIM***
		"trigger_aim": 	SkillsCore.TriggerAim.Random,
		"targets": 		SkillsCore.Target.Self,
			# ***TRIGGER***
		"trigger": 		SkillsCore.Trigger.Automatic,
		"filter": 		Activation.Filter.DamageDealt,
		"filter_actor": 	SkillsCore.Target.Self,
		"cooldown_time":	15,
	})
	
	
	
	
	var comment = """
	
append_and_create_ability(opt : Dictionary)

	***INFO***
	label: 			String
	element:		Element.Kind {Physical, Fire, Ice, Poison}
	row:			int
	
	***EFFECT***
	effect_type:	SkillsCore.EffectType { Damage, StatBuff }
	mod_stat: 		Stat.Kind 
						{ Brawn, Brains, Guts, Eyesight, Footwork, Hustle, 
						Accuracy, Crit, Evasion, Damage, Speed, Health,
						Physical, Fire, Ice, Poison,
						PhysicalResist, FireResist, IceResist, PoisonResist,MAX},
	power:			float
	
	***EFFECT AIM***
	trigger_aim : 	SkillsCore.TriggerAim { Self, EventSource, EventTarget, Random }
	ability_range:  float
	radius:			float
	targets: 		SkillsCore.Target {Self, Enemies, Allies, Empty }
	
	***TRIGGER***
	trigger: 		SkillsCore.Trigger{ Action, Automatic }
	filter: 		Activation.Filter { DamageDealt, DamageReceived, Death,
						Movement, Start, Bloodied, Miss, Dodge, Attack }
	filter_actor : 	SkillsCore.TargetAny or
					SkillsCore.Target {Self, Enemies, Allies, Empty }
	cooldown_time:	float
	
	***MOD***
	modifiers = [
		Ability.mod(
			Stat.Kind (see mod_stat above),
			Ability.ModParam { Power, AbilityRange, CooldownTime, Radius },
			float
		)
	]
	

	***EXAMPLE***

	
	append_and_create_ability({
		"label": "Fiery Fire",
		"element": Elements.Kind.Fire,
		"row": 0,
			# ***EFFECT***
		"effect_type":	SkillsCore.EffectType.StatBuff,
		"mod_stat": 		Stat.Kind.Accuracy,
		"power":			20,
			# ***EFFECT AIM***
		"trigger_aim": 	SkillsCore.TriggerAim.Self,
		"ability_range":  0,
		"radius":			0,
		"targets": 		SkillsCore.Target.Self,
			# ***TRIGGER***
		"trigger": 		SkillsCore.Trigger.Automatic,
		"filter": 		Activation.Filter.Movement,
		"filter_actor": 	SkillsCore.Target.Self,
		"cooldown_time":	1,
		"modifiers": [
			Ability.mod(Stat.Kind.Guts, Ability.ModParam.Radius, 1)
		],
	})
	
	
	SKILL IDEAS
		
	
		-Deal 10 damage to an enemy in a 5 radius (4 cooldown)
		^^^ DONE ^^^
		-When entering level, deal 20 damage to enemies in 2 range
		-When you move, buff footwork by 1 (min cooldown)
		-Deal 5 damage to enemies in a 3 radius aoe around the player
		-Deal 10 damage to enemies in a 2 tile radius, 4 range (10 ccooldown)
		-Buff brawn by 1 (5 cooldown)
		-Whenever an enemy dies, buff guts by 2
		-Whenever you miss an enemy, buff eyesight by 2
		-Whenever you take  damage, summon a blorb (3 cooldown)
		-Whenever you take damage reducing you to less than 25% hp
			deal 20 damage to enemies in range 1

		Whenever you take damage reducing you to less than 25% HP, summon a crab, range 2
		Whenever you take damage, debuff eyesight by 1 and buff brawn by 2, cooldown 5
		Whenever an enemy moves, debuff their hustle by 1, range 5 cooldown 3
		Ice damage 5 to any, range 0, cooldown 10, aoe 3
		

		
	
	"""

# syntactic sugar over like 3 calls to make an ability
func append_and_create_ability(opt: Dictionary): 
	opt.label = opt.label if opt.has('label') else SkillName.generate_name(opt.element)
	var modifiers = []
	
	#opt.element = Elements.Kind.Fire
	if opt.has('modifiers') :
		modifiers = opt.modifiers
	if !opt.has('ability_range'):
		opt['ability_range'] = 0
	if !opt.has('radius'):
		opt['radius'] = 0
	var row = opt.row
	opt.erase('modifiers')
	opt.erase('row')
	var ability: Ability = build_ability(opt)
	ability.modifiers = modifiers
	append_skill(create_ability_skill(ability), row)
	
