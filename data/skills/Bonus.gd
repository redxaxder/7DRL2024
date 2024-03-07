extends Resource

class_name Bonus

export var stat: int = 0
export var power: int = 0

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
		description += " by {0}".format([power])
	else:
		description += " by {0}".format([-power])
	return description
