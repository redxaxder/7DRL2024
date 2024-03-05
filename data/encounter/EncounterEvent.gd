extends Resource

class_name EncounterEvent



# TODO: maybe move these to EncounterEventKind
# Is this event's log message visible by default?
func is_displayed() -> bool:
	match kind:
		EncounterEventKind.Kind.Move: return false
		_: return true

# When the sim is in playback mode, does it play this event 
# normally or does it skip past it?
func is_animated() -> bool:
	match kind:
		EncounterEventKind.Kind.Move: return true
		EncounterEventKind.Kind.Attack: return true
		EncounterEventKind.Kind.AbilityActivation: return true
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
