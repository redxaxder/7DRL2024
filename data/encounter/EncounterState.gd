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
	var locations = []
	var can_target_empty = Constants.matches_mask(SkillsCore.Target.Empty, ability.effect.targets)
	if Constants.matches_mask(SkillsCore.Target.Self, ability.effect.targets):
		locations.append(actors[actor_id].location)
	var faction_mask: int = 0
	if Constants.matches_mask(SkillsCore.Target.Enemies, ability.effect.targets):
		faction_mask = faction_mask | Constants.negate_faction(actors[actor_id].faction)
	if Constants.matches_mask(SkillsCore.Target.Allies, ability.effect.targets):
		faction_mask = faction_mask | actors[actor_id].faction
	var position = actors[actor_id].location
	# locations should be all of the locations in ability.range such that
	# there is at least one valid target within the ability radius
	var r = ability.activation.ability_range
	for x in range(position.x - r, position.x + r + 1):
		for y in range(position.y - r, position.y + r + 1):
			if has_location_in_range(Vector2(x, y), ability.activation.radius, faction_mask, can_target_empty):
				locations.append(Vector2(x, y))
	return locations

func has_location_in_range(p: Vector2, radius: int, faction_mask: int, can_target_empty: bool):
	for x in range(p.x - radius, p.x + radius + 1):
		for y in range(p.y - radius, p.y + radius + 1):
			var effect_location = Vector2(x,y)
			var effect_target = lookup_actor(effect_location)
			if effect_target == null:
				if can_target_empty: return true
				else: continue
			if Constants.matches_mask(effect_target.faction, faction_mask):
				return true
	return false

func resolve_stat_buff(actor_id: int, stat: int, power: int):
	var bonus: Bonus = SkillTree.create_bonus(stat, power)
	actors[actor_id].append_bonus(bonus)

