extends Resource

class_name Bonus

var stat: int = 0
var power: int = 0

func initialize_bonus(_stat: int, bpower: int):
	stat = _stat
	power = bpower

func generate_description() -> String:
	var description = ""
	if power > 0:
		description += "Permanently raises "
	else:
		description += "Permanently lowers "
	description += Stat.NAME[stat]
	if power > 0:
		description += " by {0}.".format([power])
	else:
		description += " by {0}.".format([-power])
	return description

static func generate_bonus_description(bonuses: Array) -> String:
	var description = ""
	for bonus in bonuses:
		description += bonus.generate_description() + "\n"
	return description
