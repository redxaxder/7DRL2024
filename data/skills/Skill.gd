extends Resource

class_name Skill

enum Kind {Ability, Bonus}
export var kind: int
export var name: String
export var ability: Resource = null # Ability
export var bonuses: Array = [] # Array of Bonus

func generate_description(stats: StatBlock) -> String:
	match kind:
		Kind.Ability:
			return ability.generate_description(stats)
		Kind.Bonus:
			return Bonus.generate_bonus_description(bonuses)
	assert(false)
	return "Error: no description"

func get_color():
	if kind == Kind.Bonus:
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


#const STAT_PREMIUMS = { \
#	Brawn,
#	Brains,
#	Guts,
#	Eyesight,
#	Footwork,
#	Hustle, 
#	Accuracy,
#	Crit,
#	Evasion,
#	Damage,
#	Speed,
#	Health,
#	Physical,
#	Fire,
#	Ice,
#	Poison,
#	PhysicalResist,
#	FireResist,
#	IceResist,
#	PoisonResist,
#}
func random_bonus_skill(skill_seed: int):
	return null
