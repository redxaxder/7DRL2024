class_name Meta extends Resource

export var is_fresh: bool = true
export var unlocked: Dictionary = {}
export var gen = []

#const PATH = "user://meta.tres"
const PATH = "res://meta.tres"

func _init():
	if OS.is_userfs_persistent():
		pass

func unlock_today():
	unlocked[get_date_index()] = true



static func get_date_index() -> int:
	var t = OS.get_datetime(true)
	var i = 0
	i += t.month
	i *= 31
	i += t.day
	return i

static func index_name(i: int) -> String:
	return preload("res://misc/names.tres").value[clamp(i,0,500)]
