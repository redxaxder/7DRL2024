extends Resource

class_name EncounterEvent

# note: when an event is changed or added, the code that handles the
# event is in EncounterDriver.update()
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

var actor_idx: int = -99999
var target_idx: int = -99999
var damage: int = -99999

var target_location: Vector2 = Vector2(-99999,-99999)

var timestamp: int = -99999

var ability: Ability
var ab_name: String = "Erroneous String: DO NOT READ"

func dict() -> Dictionary:
	return 	{
		"a": actor_idx,
		"t": target_idx,
		"time": timestamp,
		"d": damage,
		"loc": target_location,
		"m": ab_name
	}
