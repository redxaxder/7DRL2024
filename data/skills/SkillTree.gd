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

static func create_bonus(bonus_kind, power: int) -> Bonus:
	var skill = Bonus.new()
	skill.initialize_bonus(bonus_kind, power)
	return skill

static func create_ability(trigger_target, trigger, effect, power: int, target, message: String, cooldown: int) -> Ability:
	assert(cooldown >= 0)
	var skill = Ability.new()
	skill.initialize_ability(trigger_target, trigger, effect, power, target, message, cooldown)
	return skill
	
static func create_ability_skill(trigger_target, trigger, effect, power: int, target, message: String, cooldown: int) -> Skill:
	var ab = create_ability(trigger_target, trigger, effect, power, target, message, cooldown)
	var skill = Skill.new()
	skill.name = message
	skill.kind = Skill.SkillKind.Ability
	skill.ability = ab
	return skill
	
static func apply_buff(ability: Ability, buff_kind):
	assert(buff_kind != null)
	ability.buff_kind = buff_kind
	
static func apply_buff_to_skill(skill: Skill, buff_kind):
	assert(skill.kind == Skill.SkillKind.Ability)
	skill.ability.buff_kind = buff_kind
	
static func create_bonus_skill(bonus_kind, power: int, skill_name: String) -> Skill:
	var bonus: Bonus = create_bonus(bonus_kind, power)
	var skill = Skill.new()
	skill.name = skill_name
	skill.kind = Skill.SkillKind.Bonus
	skill.bonus = bonus
	return skill

func hand_rolled_skill_tree():
	name = "Jack of All Trades"
	skills = []
	for i in numRows:
		skills.append([])
	var abil: Skill = create_ability_skill(Ability.TargetKind.Self, Ability.TriggerEffectKind.Damage, Ability.AbilityEffectKind.Damage, 1, Ability.TargetKind.Enemies, SkillName.generate_name(), 0)
	var abil2: Skill = create_ability_skill(Ability.TargetKind.Self, Ability.TriggerEffectKind.Activated, Ability.AbilityEffectKind.Buff, 1, Ability.TargetKind.Self, SkillName.generate_name(), 20)
	apply_buff_to_skill(abil2, Ability.BuffKind.Brawn)
	append_skill(abil2, 0)
	append_skill(abil, 1)
	append_skill(create_bonus_skill(Bonus.BonusKind.Brawn, 5, SkillName.generate_name()), 0)
	append_skill(create_bonus_skill(Bonus.BonusKind.Brains, 5, SkillName.generate_name()), 1)
	append_skill(create_bonus_skill(Bonus.BonusKind.Guts, 5, SkillName.generate_name()), 2)
	append_skill(create_bonus_skill(Bonus.BonusKind.Eyesight, 5, SkillName.generate_name()), 0)
	append_skill(create_bonus_skill(Bonus.BonusKind.Footwork, 5, SkillName.generate_name()), 1)
	append_skill(create_bonus_skill(Bonus.BonusKind.Hustle, 5, SkillName.generate_name()), 2)
