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


const STAT_PREMIUM = { \
	Stat.Kind.Brawn: 1,
	Stat.Kind.Brains: 1,
	Stat.Kind.Guts: 1,
	Stat.Kind.Eyesight: 1,
	Stat.Kind.Footwork: 1,
	Stat.Kind.Hustle: 1,
	Stat.Kind.Accuracy: 3,
	Stat.Kind.Crit: 3,
	Stat.Kind.Evasion: 3,
	Stat.Kind.Damage: 3,
	Stat.Kind.Speed: 3,
	Stat.Kind.Health: 3,
	Stat.Kind.Physical: 2,
	Stat.Kind.Fire: 2,
	Stat.Kind.Ice: 2,
	Stat.Kind.Poison: 2,
	Stat.Kind.PhysicalResist: 5,
	Stat.Kind.FireResist: 5,
	Stat.Kind.IceResist: 5,
	Stat.Kind.PoisonResist: 5,
}
static func random_bonus(skill_seed: int) -> Array:
	var rng = RandomNumberGenerator.new()
	rng.seed = skill_seed
	var plus = Bonus.new()
	var magnitude = rng.randi() % 4
	var variance = (rng.randf() - 0.5) /6
	var power = (1 + magnitude) * 10 * (1+ variance)
	plus.stat = rng.randi() % Stat.Kind.MAX
	plus.power = power * STAT_PREMIUM[plus.stat]
	if magnitude == 0: return [plus]
	var minus = Bonus.new()
	var minus_stats = []
	for s in Stat.Kind.MAX:
		if s == plus.stat: continue
		if Stat.MINIMUM[s] == 0: continue
		minus_stats.append(s)
	minus.stat = minus_stats[rng.randi() % minus_stats.size()]
	minus.power = plus.power * -0.5
	minus.power *= STAT_PREMIUM[minus.stat]
	return  [plus, minus]
