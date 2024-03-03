extends Resource

class_name SkillTree

export var skills: Array = [] # 2D Array of Skill

export var skillsPerRow: int = 5
export var numRows: int = 3

func addSkill(skillName: String, i: int, _j:int):
	var skill = Skill.new()
	skill.name = skillName
	skills[i].append(skill)
	return skill

static func create_bonus(bonus_kind, power: int) -> Bonus:
	var skill = Bonus.new()
	skill.initialize_bonus(bonus_kind, power)
	return skill

static func create_ability(trigger_target, trigger, effect, power, target, message) -> Ability:
	var skill = Ability.new()
	skill.initialize_ability(trigger_target, trigger, effect, power, target, message)
	return skill
