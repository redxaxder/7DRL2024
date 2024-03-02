extends Resource

class_name EncounterEvent

export var delta: int = 0

# note: when an event is changed or added, the code that handles the
# event is in DataUtil.update()
enum EventKind {Attack, Move, Death}

func is_displayed() -> bool:
	match kind:
		EventKind.Move: return false
		_: return true


var kind

var actor_idx: int
var target_idx: int
var damage: int

var target_location: Vector2

