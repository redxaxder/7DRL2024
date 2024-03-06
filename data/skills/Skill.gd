extends Resource

class_name Skill

enum Kind {Ability, Bonus}
var kind

export var name: String

var ability: Ability = null
var bonus: Bonus = null

func generate_description(stats: StatBlock) -> String:
	match kind:
		Kind.Ability:
			return ability.generate_description(stats)
		Kind.Bonus:
			return bonus.generate_description()
	assert(false)
	return "Error: no description"
