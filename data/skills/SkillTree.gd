extends Resource

class_name SkillTree

export var skills: Array = [] # 2D Array of Skill

export var skillsPerRow: int = 5
export var numRows: int = 3

func addSkill(skillName: String, i: int, _j:int) -> Skill:
	var skill = Skill.new(skillName)
	skills[i].append(skill)
	return skill

static func create_bonus_skill(bonus_kind, power: int) -> Skill:
	var skill = Skill.new("")
	skill.initialize_bonus(bonus_kind, power)
	return skill
