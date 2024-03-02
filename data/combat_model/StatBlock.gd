extends Resource

class_name StatBlock

# core stats
var brawn: int
var brains: int
var guts: int
var eyesight: int
var footwork: int
var hustle: int

# derived stats
func max_hp() -> int:
	return brawn + guts
	
func accuracy() -> int:
	return eyesight + brains
	
func speed() -> int:
	return footwork + hustle
	
func evasion() -> int:
	return footwork + guts

func damage() -> int:
	return brawn + brains
	
func crit() -> int:
	return eyesight + hustle

func initialize(_brawn: int, _brains: int, _guts: int, _eyesight: int, _footwork: int, _hustle: int):
	brawn = _brawn
	brains = _brains
	guts = _guts
	eyesight = _eyesight
	footwork = _footwork
	hustle = _hustle
