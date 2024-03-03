extends Resource

class_name Bonus

enum BonusKind {Brawn, Brains, Guts, Eyesight, Footwork, Hustle}
var bonus_kind
var bonus_power: int = 0

func initialize_bonus(bkind, power: int):
	bonus_kind = bkind
	bonus_power = power
