extends Resource

class_name EncounterState
# note for when state is changed
#  - the code that handles duplicating states is DataUtil.dup_state()
#  - the code that handles displaying states is ViewHistory._refresh()

var player: int
var actors: Array # [CombatEntity]
var map: Dictionary # [location Vector2, index in the actor array]
					# represent walls etc with -1?
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
	map.erase(a.location)
	a.location = Vector2(-1000,-1000)

func add_actor(e: CombatEntity, loc: Vector2):
	print("actor spawn: {0},{1}".format([loc.x, loc.y]))
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
	
func get_ability_target(actor_id: int, ability: Ability) -> Vector2:
	var targets = find_valid_targets(actor_id, ability)
	if targets.size() > 0:
		targets.shuffle()
		return targets[0]
	return Vector2.INF
	
func find_valid_targets(actor_id: int, ability: Ability) -> Array:
	var faction_mask: int = 0
	match ability.effect_target_kind:
		Ability.TargetKind.Self:
			return [actors[actor_id].location]
		Ability.TargetKind.Any:
			faction_mask = Constants.ANY_FACTION
		Ability.TargetKind.Enemies:
			faction_mask = Constants.negate_faction(actors[actor_id].faction)
		Ability.TargetKind.Allies:
			faction_mask = actors[actor_id].faction
	var position = actors[actor_id].location
	var locations = []
	# locations should be all of the locations in ability.range such that
	# there is at least one valid target within the ability radius
	for x in range(position.x - ability.ability_range, position.x + ability.ability_range + 1):
		for y in range(position.y - ability.ability_range, position.y + ability.ability_range + 1):
			if has_location_in_range(Vector2(x, y), ability.aoe_radius, faction_mask):
				locations.append(Vector2(x, y))
	return locations

func has_location_in_range(location: Vector2, radius: int, faction_mask: int):
	for actor in actors: 
		var vec: Vector2 = (actor.location - location).abs()
		var distance = max(vec.x, vec.y)
		if distance <= radius and Constants.matches_mask(actor.faction, faction_mask):
			return true
	return false

# state.resolve_buff(target.entity_index, ability.buff_kind, ability.power)
func resolve_buff(actor_id: int, buff_kind, power: int):
	assert(buff_kind != null)
	var bonus: Bonus = SkillTree.create_bonus(buff_kind, power)
	actors[actor_id].append_bonus(bonus)
