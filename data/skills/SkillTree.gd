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

static func create_bonus(stat, power: int) -> Bonus:
	var skill = Bonus.new()
	skill.initialize_bonus(stat, power)
	return skill

static func create_ability_skill(ability: Ability) -> Skill:
	var skill = Skill.new()
	skill.name = ability.name
	skill.kind = Skill.Kind.Ability
	skill.ability = ability
	return skill
	
static func create_bonus_skill(stat: int, power: int, skill_name: String) -> Skill:
	var bonus: Bonus = create_bonus(stat, power)
	var skill = Skill.new()
	skill.name = skill_name
	skill.kind = Skill.Kind.Bonus
	skill.bonus = bonus
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
	var abil: Skill = create_ability_skill(build_ability({
		"label": SkillName.generate_name(),
		"trigger": SkillsCore.Trigger.Automatic,
		"filter": Activation.Filter.DamageDealt,
		"filter_actor": SkillsCore.TargetAny,
		"trigger_aim": SkillsCore.TriggerAim.Self,
		"effect_type": SkillsCore.EffectType.StatBuff,
		"ability_range": 4,
		"mod_stat": Stat.Kind.Health,
		"power": 10,
		"targets": SkillsCore.Target.Self,
		}))
# warning-ignore:unused_variable
	var my_cool_skill: Skill = create_ability_skill(build_ability({
		"label": SkillName.generate_name(),
		"trigger": SkillsCore.Trigger.Automatic,
		"filter": Activation.Filter.DamageRecieved,
		"filter_actor": SkillsCore.Target.Self,
		"trigger_aim": SkillsCore.TriggerAim.Self,
		"effect_type": SkillsCore.EffectType.StatBuff,
		"mod_stat": Stat.Kind.Damage,
		"power": 1000,
		"targets": SkillsCore.Target.Self
	}))
	var my_cool_death_ability: Ability = build_ability({
		"label": SkillName.generate_name(),
		"trigger": SkillsCore.Trigger.Automatic,
		"filter": Activation.Filter.Death,
		"filter_actor": SkillsCore.Target.Enemies,
		"trigger_aim": SkillsCore.TriggerAim.Random,
		"effect_type": SkillsCore.EffectType.StatBuff,
		"mod_stat": Stat.Kind.Speed,
		"ability_range": 0,
		"power": -5,
		"targets": SkillsCore.Target.Enemies,
	})
	my_cool_death_ability.modifiers = [
		Ability.mod(Stat.Kind.Health, Ability.ModParam.AbilityRange, 100)
	]
	
	var aoe_test_ability: Ability = build_ability({
		"label": SkillName.generate_name(),
		"trigger": SkillsCore.Trigger.Action,
		"effect_type": SkillsCore.EffectType.Damage,
		"ability_range": 0,
		"power": 1,
		"radius": 1,
		"cooldown_time": 1,
		"targets": SkillsCore.Target.Enemies,
	})
	aoe_test_ability.modifiers = [
		Ability.mod(Stat.Kind.Health, Ability.ModParam.Radius, 100)
	]

#	var abil2: Skill = create_ability_skill(build_ability({
#		"label": SkillName.generate_name(),
#		"target": SkillsCore.Target.Self,
#		"effect_type": SkillsCore.EffectType.StatBuff,
#		"mod_stat": Stat.Kind.Health,
#		"power": 20,
#		}))
#	append_skill(abil2, 0)


	# Deal 10 damage to an enemy in a 5 radius (4 cooldown)
	append_and_create_ability({
		"trigger": SkillsCore.Trigger.Action,
		"effect_type": SkillsCore.EffectType.Damage,
		"ability_range": 0,
		"power": 10,
		"radius": 1,
		"cooldown_time": 4,
		"targets": SkillsCore.Target.Enemies,
		"modifiers": [
			# as a rule, single digit coefficients on mods
			Ability.mod(Stat.Kind.Health, Ability.ModParam.Radius, 10)
		],
		"row": 2
	})
	
	append_skill(create_ability_skill(aoe_test_ability), 1)
	
	append_skill(create_bonus_skill(Stat.Kind.Brawn, 5, SkillName.generate_name()), 0)
	append_skill(create_bonus_skill(Stat.Kind.Brains, 5, SkillName.generate_name()), 1)
	append_skill(create_bonus_skill(Stat.Kind.Guts, 5, SkillName.generate_name()), 2)
	append_skill(create_bonus_skill(Stat.Kind.Eyesight, 5, SkillName.generate_name()), 0)
	append_skill(create_bonus_skill(Stat.Kind.Footwork, 5, SkillName.generate_name()), 1)
	append_skill(create_bonus_skill(Stat.Kind.Hustle, 5, SkillName.generate_name()), 2)
	
	
	var comment = """
	
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
		
	
		damage
		move
		attack
		hit
		target dies
		
		DamageDealt, 
		DamageRecieved,
		Death,
		#cheap to add
		# movement
		# uses ability
		# misses
		# encounter start
		# fixed threshold (25%) "bloodied"
		# attack
		monster summon

	
	enum EffectType
		Damage
		StatBuff
		summons
		accelerate turn priority (via "bonus time")
		
	
	"""

# syntactic sugar over like 3 calls to make an ability
func append_and_create_ability(opt: Dictionary): 
	opt.label = SkillName.generate_name()
	var modifiers = opt.modifiers
	var row = opt.row
	opt.erase('modifiers')
	opt.erase('row')
	var ability: Ability = build_ability(opt)
	ability.modifiers = modifiers
	append_skill(create_ability_skill(ability), row)
	
