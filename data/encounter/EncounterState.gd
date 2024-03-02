extends Resource

class_name EncounterState
# note for when state is changed
#  - the code that handles duplicating states is DataUtil.dup_state()
#  - the code that handles displaying states is ViewHistory._refresh()

var player: int
var actors: Array # [CombatEntity]
var map: Dictionary # [location Vector2, index in the actor array]
					# represent walls etc with -1?

func player() -> CombatEntity:
	return actors[player]

func lookup_actor(location: Vector2) -> CombatEntity:
	var t = map.get(location, null)
	if t == null:
		return null
	return actors[t]

func set_location(actor_id: int, target_loc: Vector2):
	if map.get(target_loc, null) != null:
		push_error("Collising locations! The explosion envelops all.")
	var a = actors[actor_id]
	# remove current location from map
	map.erase(a.location)
	# set new loc, and add it to map
	a.location = target_loc
	map[target_loc] = actor_id
