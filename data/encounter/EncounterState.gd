extends Resource

class_name EncounterState

var player: int
var actors: Array # [CombatEntity]
var map: Dictionary # [location Vector2, index in the actor array]
var elapsed_time: int = 0

func get_player() -> CombatEntity:
	return actors[player]

func lookup_actor(location: Vector2) -> CombatEntity:
	var t = map.get(location, null)
	if t == null:
		return null
	return actors[t]

func remove_actor(actor_ix: int):
	var a = actors[actor_ix]
# warning-ignore:return_value_discarded
	map.erase(a.location)
	a.location = Vector2(-1000,-1000)

func add_actor(e: CombatEntity, loc: Vector2):
	var next_index = actors.size()
	e.entity_index = next_index
	actors.push_back(e)
	if !map.has(loc):
		set_location(next_index, loc)
		e.time_spent = next_index

func is_occupied(target_loc: Vector2) -> bool:
	return map.get(target_loc, null) != null

func set_location(actor_id: int, target_loc: Vector2):
	if is_occupied(target_loc):
		print("Colliding locations! {0}  {1} at {2},{3}".format([
			actor_id,
			map.get(target_loc, null),
			target_loc.x,
			target_loc.y
		]))
		push_error("Colliding locations! The explosion envelops all.")
		assert(false)
	var a = actors[actor_id]
	# remove current location from map
# warning-ignore:return_value_discarded
	map.erase(a.location)
	# set new loc, and add it to map
	a.location = target_loc
	map[target_loc] = actor_id
	
func resolve_attack(target_id: int, damage: int):
	var target: CombatEntity = actors[target_id]
	target.cur_hp -= damage

func resolve_stat_buff(actor_id: int, stat: int, power: int):
	var bonus: Bonus = Bonus.new()
	bonus.stat = stat
	bonus.power = power
	var actor: CombatEntity = actors[actor_id]
	var prev_max_hp = actor.stats.max_hp()
	actors[actor_id].append_bonus(bonus)
	var new_max_hp = actor.stats.max_hp()
	if new_max_hp < actor.cur_hp:
		actor.cur_hp = new_max_hp
	var hp_increase = max(0,new_max_hp - prev_max_hp) # temporary, should remove after encounter
	actor.cur_hp += hp_increase

