extends Resource

class_name StatBlock

var stats: Array = [0,0,0,0,0,0]

var _bonuses: Dictionary
# bonuses
#var _bonuses: Array

func clear_bonuses():
	_bonuses = {}

func apply_bonus(bonus: Bonus):
	var it = _bonuses.get(bonus.stat, 0)
	it += bonus.power
	_bonuses[bonus.stat] = it
#	_bonuses.append(bonus)

func get_base_stat(stat: int) -> int:
	if stat < 6:
		return stats[stat]
	else:
		match stat:
			Stat.Kind.Health: return brawn() + guts()
			Stat.Kind.Accuracy: return eyesight() + brains()
			Stat.Kind.Speed: 	return footwork() + hustle()
			Stat.Kind.Evasion: return footwork() + guts()
			Stat.Kind.Damage: return brawn() + brains()
			Stat.Kind.Crit: return eyesight() + hustle()
	return 0

func get_elemental_power_multiplier(element: int) -> float:
	var elemental_power_stat = Elements.ATTACK[element]
	var elemental_bonus = float(get_modified_stat(elemental_power_stat))
	return elemental_bonus / 100.0 + 1

func get_modified_stat(stat: int) -> int:
	var base = get_base_stat(stat)
	var modified = base + _bonuses.get(stat,0)
	return int(max(Stat.MINIMUM[stat],modified)) 

func brawn(): return get_modified_stat(Stat.Kind.Brawn)
func brains(): return get_modified_stat(Stat.Kind.Brains)
func guts(): return get_modified_stat(Stat.Kind.Guts)
func eyesight(): return get_modified_stat(Stat.Kind.Eyesight)
func footwork(): return get_modified_stat(Stat.Kind.Footwork)
func hustle(): return get_modified_stat(Stat.Kind.Hustle)

func brawn_desc(): return "affects Health & Attack"
func brains_desc(): return "affects Accuracy & Attack"
func guts_desc(): return "affects Health & Evasion"
func eyesight_desc(): return "affects Accuracy & Crit"
func footwork_desc(): return "affects Speed & Evasion"
func hustle_desc(): return "affects Speed & Crit"

# derived stats
func max_hp() -> int: return get_modified_stat(Stat.Kind.Health)
func accuracy() -> int: return get_modified_stat(Stat.Kind.Accuracy)
func speed() -> int: return get_modified_stat(Stat.Kind.Speed)
func evasion() -> int: return get_modified_stat(Stat.Kind.Evasion)
func damage() -> int: return get_modified_stat(Stat.Kind.Damage)
func crit() -> int: return get_modified_stat(Stat.Kind.Crit)

#elemental stats
func physical() -> int: return get_modified_stat(Stat.Kind.Physical)
func poison() -> int: return get_modified_stat(Stat.Kind.Poison)
func fire() -> int: return get_modified_stat(Stat.Kind.Fire)
func ice() -> int: return get_modified_stat(Stat.Kind.Ice)
func physical_resist() -> int: return get_modified_stat(Stat.Kind.PhysicalResist)
func poison_resist() -> int: return get_modified_stat(Stat.Kind.PoisonResist)
func fire_resist() -> int: return get_modified_stat(Stat.Kind.FireResist)
func ice_resist() -> int: return get_modified_stat(Stat.Kind.IceResist)

func crit_mult() -> float:
	var c = float(crit())
	return (200 + 2*c)/100

func crit_chance() -> float:
	var c = float(crit())
	return c/(100 + 2*c)

func initialize_array(array: Array):
	stats  = array.duplicate()
	_bonuses = {}

func initialize(_brawn: int, _brains: int, _guts: int, _eyesight: int, _footwork: int, _hustle: int):
	stats = [_brawn, _brains, _guts, _eyesight, _footwork, _hustle]
	_bonuses = {}
