extends Resource

class_name Bonus

enum BonusKind {Brawn, Brains, Guts, Eyesight, Footwork, Hustle}
var kind
var power: int = 0

func initialize_bonus(bkind, bpower: int):
	kind = bkind
	power = bpower

func generate_description() -> String:
	var description = ""
	if power > 0:
		description += "Permanently raises "
	else:
		description += "Permanently lowers "
	match kind:
		BonusKind.Brawn:
			description += "Brawn"
		BonusKind.Brains:
			description += "Brains"
		BonusKind.Guts:
			description += "Guts"
		BonusKind.Eyesight:
			description += "Eyesight"
		BonusKind.Footwork:
			description += "Footwork"
		BonusKind.Hustle:
			description += "Hustle"
	if power > 0:
		description += " by {0}".format([power])
	else:
		description += " by {0}".format([-power])
	return description
