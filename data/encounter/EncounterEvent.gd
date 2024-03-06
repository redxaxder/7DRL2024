extends Resource

class_name EncounterEvent




var kind

var actor_idx: int = -99999
var actor_name: String = "Erroneous String: DO NOT READ"
var target_idx: int = -99999
var target_name: String = "Erroneous String: DO NOT READ"
var damage: int = -99999
var is_crit: bool = false
var element: int = Elements.Kind.Physical

var stat: int = -9999

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
