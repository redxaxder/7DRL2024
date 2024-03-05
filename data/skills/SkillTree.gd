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
	var abil: Skill = create_ability_skill(build_ability({
		"label": SkillName.generate_name(),
		"trigger": SkillsCore.Trigger.Automatic,
		"filter": Activation.Filter.DamageDealt,
		"filter_actor": SkillsCore.TargetAny,
		"trigger_aim": SkillsCore.TriggerAim.Random,
		"trigger_effect": SkillsCore.EffectType.Damage,
		"effect_type": SkillsCore.EffectType.Damage,
		"ability_range": 3,
		"power": 5,
		"target": SkillsCore.Target.Enemies,
		}))
#	var abil2: Skill = create_ability_skill(build_ability({
#		"label": SkillName.generate_name(),
#		"target": SkillsCore.Target.Self,
#		"effect_type": SkillsCore.EffectType.StatBuff,
#		"mod_stat": Stat.Kind.Health,
#		"power": 20,
#		}))
#	append_skill(abil2, 0)
	append_skill(abil, 1)
#	append_skill(create_ability_skill(build_ability({
#		"label": SkillName.generate_name(),
#
#		})), 2)
	append_skill(create_bonus_skill(Stat.Kind.Brawn, 5, SkillName.generate_name()), 0)
	append_skill(create_bonus_skill(Stat.Kind.Brains, 5, SkillName.generate_name()), 1)
	append_skill(create_bonus_skill(Stat.Kind.Guts, 5, SkillName.generate_name()), 2)
	append_skill(create_bonus_skill(Stat.Kind.Eyesight, 5, SkillName.generate_name()), 0)
	append_skill(create_bonus_skill(Stat.Kind.Footwork, 5, SkillName.generate_name()), 1)
	append_skill(create_bonus_skill(Stat.Kind.Hustle, 5, SkillName.generate_name()), 2)
