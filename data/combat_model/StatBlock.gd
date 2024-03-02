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

func _init(brawn: int, brains: int, guts: int, eyesight: int, footwork: int, hustle: int):
	self.brawn = brawn
	self.brains = brains
	self.guts = guts
	self.eyesight = eyesight
	self.footwork = footwork
	self.hustle = hustle
