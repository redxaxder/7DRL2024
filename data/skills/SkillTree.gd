extends Resource

class_name SkillTree

export var skills: Array = [] # 2D Array of Skill

export var skillsPerRow: int = 5
export var numRows: int = 3

func addSkill(skillName: String, i: int, j:int) -> Skill:
	var skill = Skill.new(skillName)
	skills[i].append(skill)
	return skill
