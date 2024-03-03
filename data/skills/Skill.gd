extends Resource

class_name Skill

enum SkillKind {Ability, Bonus}
var kind

enum BonusKind {None, Brawn, Brains, Guts, Eyesight, Footwork, Hustle}
var bonus_kind = BonusKind.None
var bonus_power: int = 0

export var name: String

	
func initialize_bonus(bkind, power: int):
	assert(bkind != BonusKind.None && bkind <= BonusKind.Hustle)
	kind = SkillKind.Bonus
	bonus_kind = bkind
	bonus_power = power
