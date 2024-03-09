extends Resource
class_name Meta

export var is_fresh: bool = true
export var unlocked: Dictionary = {}

const PATH = "user://meta.tres"

func unlock_today() -> Resource:
	unlocked[get_date_index()] = true
	return self

func unlock_random(i: int) -> Resource:
	i = i % 366
	for n in 400:
		var it = (i + n) % 366
		if !unlocked.get(it, false):
			unlocked[it] = true
			break
	return self

func get_unlocked() -> Array:
	return unlocked.keys()

func save():
	ResourceSaver.save(PATH, self)
	
const MONTHS = [31,29,31,30,31,30,31,31,30,31,30,31]

static func get_date_index() -> int:
	var t = OS.get_datetime(true)
	var i = 0
	i += t.month - 1
	i *= 31
	i += t.day -1
	return i

static func tree_name(tree_id: int) -> String:
	return preload("res://misc/names.tres").value[clamp(tree_id,0,500)]

