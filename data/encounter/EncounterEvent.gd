extends Resource

class_name EncounterEvent

# note: when an event is changed or added, the code that handles the
# event is in EncounterDriver.update()
enum Kind {Attack, Move, Death, AbilityActivation, Damage}

# Is this event's log message visible by default?
func is_displayed() -> bool:
	match kind:
		Kind.Move: return false
		_: return true

# When the sim is in playback mode, does it play this event 
# normally or does it skip past it?
func is_animated() -> bool:
	match kind:
		Kind.Move: return true
		Kind.Attack: return true
		Kind.AbilityActivation: return true
		_: return false


var kind

var actor_idx: int = -99999
var actor_name: String = "Erroneous String: DO NOT READ"
var target_idx: int = -99999
var target_name: String = "Erroneous String: DO NOT READ"
var damage: int = -99999
var elements: Array

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
		"m": ab_name,
		"an": actor_name,
		"tn": target_name,
	}
