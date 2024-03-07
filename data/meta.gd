class_name Meta extends Resource

export var is_fresh: bool = true
export var unlocked: Dictionary = {}

const PATH = "user://meta.tres"

func _init():
	if OS.is_userfs_persistent():
		pass

func unlock_today():
	unlocked[get_date_id()] = true


static func get_date_id() -> int:
	var t = OS.get_datetime(true)
	var i = 0
	i += t.month
	i *= 100
	i += t.day
	return i

