extends Resource

class_name Bonus

enum Kind {Brawn, Brains, Guts, Eyesight, Footwork, Hustle}
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
		Kind.Brawn:
			description += "Brawn"
		Kind.Brains:
			description += "Brains"
		Kind.Guts:
			description += "Guts"
		Kind.Eyesight:
			description += "Eyesight"
		Kind.Footwork:
			description += "Footwork"
		Kind.Hustle:
			description += "Hustle"
	if power > 0:
		description += " by {0}".format([power])
	else:
		description += " by {0}".format([-power])
	return description
