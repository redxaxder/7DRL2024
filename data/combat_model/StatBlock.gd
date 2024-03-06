extends Resource

class_name StatBlock

var stats: Array = [0,0,0,0,0,0]

# bonuses
var bonuses: Array

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

func get_modified_stat(stat: int) -> int:
	var accumulated: int = get_base_stat(stat)
	for bonus in bonuses:
		if bonus.stat == stat:
			accumulated += bonus.power
	#TODO (C?)
	# right now accumulated penalties down below the mimumum will cancel later incoming buffs
	# make it not worklike that, maybe
	return int(max(Stat.MINIMUM[stat],accumulated)) 

func brawn(): return get_modified_stat(Stat.Kind.Brawn)
func brains(): return get_modified_stat(Stat.Kind.Brains)
func guts(): return get_modified_stat(Stat.Kind.Guts)
func eyesight(): return get_modified_stat(Stat.Kind.Eyesight)
func footwork(): return get_modified_stat(Stat.Kind.Footwork)
func hustle(): return get_modified_stat(Stat.Kind.Hustle)

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
	bonuses = []

func initialize(_brawn: int, _brains: int, _guts: int, _eyesight: int, _footwork: int, _hustle: int):
	stats = [_brawn, _brains, _guts, _eyesight, _footwork, _hustle]
	bonuses = []
