extends Resource

class_name Skill

enum SkillKind {Ability, Bonus}
var kind

export var name: String

var ability: Ability = null
var bonus: Bonus = null

func generate_name():
	pass
