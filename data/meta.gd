extends Resource
class_name Meta

export var is_fresh: bool = true
export var unlocked: Dictionary = {}

const PATH = "user://meta.tres"

func unlock_today():
	unlocked[get_date_index()] = true

func unlock_random(rng: RandomNumberGenerator):
	var i = rng.randi() % 366
	while unlocked.get(i,false):
		i += 1
	unlocked[i] = true

func get_unlocked() -> Array:
	return unlocked.keys()

func save():
	ResourceSaver.save(PATH, self)
	
const MONTHS = [31,29,31,30,31,30,31,31,30,31,30,31]

static func get_date_index() -> int:
	var t = OS.get_datetime(true)
	var i = 0
	i += t.month
	i *= 31
	i += t.day
	return i

static func tree_name(tree_id: int) -> String:
	return preload("res://misc/names.tres").value[clamp(tree_id,0,500)]

