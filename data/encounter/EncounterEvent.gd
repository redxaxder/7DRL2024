extends Resource

class_name EncounterEvent

export var delta: int = 0

# note: when an event is changed or added, the code that handles the
# event is in DataUtil.update()
enum EventKind {Attack, Move, Death, AbilityActivation}

# Is this event's log message visible by default?
func is_displayed() -> bool:
	match kind:
		EventKind.Move: return false
		_: return true

# When the sim is in playback mode, does it play this event 
# normally or does it skip past it?
func is_animated() -> bool:
	match kind:
		EventKind.Move: return true
		EventKind.Attack: return true
		EventKind.AbilityActivation: return true
		_: return false


var kind

var actor_idx: int
var target_idx: int
var damage: int

var target_location: Vector2

var timestamp: int

var ability: Ability

func dict() -> Dictionary:
	return 	{
		"a": actor_idx,
		"t": target_idx,
		"time": timestamp,
		"d": damage,
		"loc": target_location,
	}
