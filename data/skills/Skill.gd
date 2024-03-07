extends Resource

class_name Skill

enum Kind {Ability, Bonus}
export var kind: int
export var name: String
export var ability: Resource = null # Ability
export var bonus: Resource = null # Bonus

func generate_description(stats: StatBlock) -> String:
	match kind:
		Kind.Ability:
			return ability.generate_description(stats)
		Kind.Bonus:
			return bonus.generate_description()
	assert(false)
	return "Error: no description"
