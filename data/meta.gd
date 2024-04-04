extends Resource
class_name Meta

export var is_fresh: bool = true
export var unlocked: Dictionary = {}
export var won: Dictionary = {}

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

func did_win(id: int) -> bool:
	return won.get(id, false)

func win(id: int) -> Resource:
	won[id] = true
	return self

func get_unlocked() -> Array:
	var unlocked_indices = unlocked.keys()
	unlocked_indices.sort()
	return unlocked_indices


func save():
	ResourceSaver.save(PATH, self)
	
const MONTHS = [31,29,31,30,31,30,31,31,30,31,30,31]

static func get_date_index() -> int:
	var t = OS.get_datetime(true)
	var i = 0
	for m in (t.month -1):
		i += MONTHS[m]
	i += t.day -1
	return i

# index -> MMDD format
static func display_date_index(ix: int) -> String:
	var m = 0
	while true:
		var days = MONTHS[m]
		if ix < days:
			break
		else:
			ix -= days
		m += 1
	var result = ("%02d" % (m+1)) + ("%02d" % (ix+1))
	return result

static func tree_name(tree_id: int) -> String:
	return preload("res://misc/names.tres").value[clamp(tree_id,0,500)]

