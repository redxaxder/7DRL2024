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

func get_color():
	if bonus:
		return Color("#b700ff")
	if ability && ability.effect:
		if ability.effect.element == Elements.Kind.Physical:
			return Color("#e7ad47")
		elif ability.effect.element == Elements.Kind.Poison:
			return Color("#24ff7a")
		elif ability.effect.element == Elements.Kind.Fire:
			return Color("#ff2503")
		elif ability.effect.element == Elements.Kind.Ice:
			return Color("#3eb7ff")
	return RandomUtil.color_hash(name)
