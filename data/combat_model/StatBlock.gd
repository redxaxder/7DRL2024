extends Resource

class_name StatBlock

# core stats
var brawn: int setget ,_get_brawn
var brains: int setget ,_get_brains
var guts: int setget ,_get_guts
var eyesight: int setget ,_get_eyesight
var footwork: int setget ,_get_footwork
var hustle: int setget ,_get_hustle

# bonuses
var bonuses: Array

# setters and getters
func _get_brawn():
	var accumulated_power: int = 0
	for bonus in bonuses:
		if bonus.kind == Bonus.Kind.Brawn:
			accumulated_power += bonus.power
	return brawn + accumulated_power
	
func _get_brains():
	var accumulated_power: int = 0
	for bonus in bonuses:
		if bonus.kind == Bonus.Kind.Brains:
			accumulated_power += bonus.power
	return brains + accumulated_power
	
func _get_guts():
	var accumulated_power: int = 0
	for bonus in bonuses:
		if bonus.kind == Bonus.Kind.Guts:
			accumulated_power += bonus.power
	return guts + accumulated_power
	
func _get_eyesight():
	var accumulated_power: int = 0
	for bonus in bonuses:
		if bonus.kind == Bonus.Kind.Eyesight:
			accumulated_power += bonus.power
	return eyesight + accumulated_power
	
func _get_footwork():
	var accumulated_power: int = 0
	for bonus in bonuses:
		if bonus.kind == Bonus.Kind.Footwork:
			accumulated_power += bonus.power
	return footwork + accumulated_power
	
func _get_hustle():
	var accumulated_power: int = 0
	for bonus in bonuses:
		if bonus.kind == Bonus.Kind.Hustle:
			accumulated_power += bonus.power
	return hustle + accumulated_power

# derived stats
func max_hp() -> int:
	return _get_brawn() + _get_guts()
	
func accuracy() -> int:
	return _get_eyesight() + _get_brains()
	
func speed() -> int:
	return _get_footwork() + _get_hustle()
	
func evasion() -> int:
	return _get_footwork() + _get_guts()

func damage() -> int:
	return _get_brawn() + _get_brains()
	
func crit() -> int:
	return _get_eyesight() + _get_hustle()

func initialize(_brawn: int, _brains: int, _guts: int, _eyesight: int, _footwork: int, _hustle: int):
	brawn = _brawn
	brains = _brains
	guts = _guts
	eyesight = _eyesight
	footwork = _footwork
	hustle = _hustle
	bonuses = []
