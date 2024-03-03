extends Resource

class_name EncounterDriver


const EncEvent = preload("res://data/encounter/EncEvent.gd")
const Map = preload("res://data/map/Map.gd")

var current_time = 0
var queue: PriorityQueue
var cur_state: EncounterState

const dirs: Array = [Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1)]
const cardinal: Array = [Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1)]
const diagonal: Array = [Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1), Vector2(1, -1)]
var history: EncounterHistory
var cur_idx: int = 0

var map: Map

var encounter_seed
func initialize(use_seed: int = 0, p_map: Map = null):
	if use_seed == 0:
		encounter_seed = randi()
	else:
		encounter_seed = use_seed
	prints("encounter seed", encounter_seed)

	queue = PriorityQueue.new()
	cur_state = EncounterState.new()
	history = EncounterHistory.new()
	
	map = p_map
	map.generate()
	
	cur_state.actors = []
	
	var player = CombatEntity.new()
	player.initialize(15, 15, 30, 20, 10, 10, Constants.PLAYER_FACTION)
	player.actor_type = Actor.Type.Player
	player.append_bonus(SkillTree.create_bonus(Bonus.BonusKind.Brawn, 5))
	player.append_ability(SkillTree.create_ability(Ability.TargetKind.Self, Ability.TriggerEffectKind.Damage, Ability.AbilityEffectKind.Damage, 1, Ability.TargetKind.Enemies, "Counter!"))
	insert_entity(player, Vector2(1, 1))
	
	for _i in range(3):
		var nme = create_enemy()
		insert_entity(nme, Vector2(randi() % 5 + 5, randi() % 10))
	
	history.add_state(DataUtil.deep_dup(cur_state))
	
	
func create_enemy() -> CombatEntity:
	var nme = CombatEntity.new()
	var reference_nme_idx = randi() % (Actor.Type.size() - 1) + 1
	nme.initialize_with_block(Actor.get_stat_block(reference_nme_idx), Constants.ENEMY_FACTION)	
	nme.actor_type = Actor.get_type(reference_nme_idx)
	return nme

func insert_entity(e: CombatEntity, loc: Vector2):
	if !cur_state.map.has(loc):
		e.entity_index = cur_idx
		cur_state.actors.push_back(e)
		cur_state.set_location(cur_idx, loc)
		queue.insert(e, 0)
		e.time_spent = cur_idx
		cur_idx += 1


func tick() -> bool:
	# 0. is the player alive?
	if !cur_state.get_player().is_alive():
		return false
	# 0.1. are there any enemies alive?
	var enemies_alive = false
	for actor in cur_state.actors:
		if actor.is_alive() and actor.faction != Constants.PLAYER_FACTION:
			enemies_alive = true
			break
	if !enemies_alive: return false
	
	# 1. grab the first living thing in the priority queue
	var actor = queue.pop_front()
	while !actor.is_alive() and queue.size() > 0:
		actor = queue.pop_front()
	if !actor.is_alive():
		return false
	# 2. run its AI
	#    AI produces an EncounterEvent
	var evt: EncounterEvent = tick_ai(actor)

	# 3. record that event
	while evt != null:
		history.add_event(evt)
	# warning-ignore:return_value_discarded
		evt = update(cur_state, evt)
		history.add_state(DataUtil.deep_dup(cur_state))

	# 5. If actor is still alive, re-insert it into the priority queue
	actor.time_spent += int(100.0 / float(actor.stats.speed()))
	queue.insert(actor, actor.time_spent)
	
	return true

func tick_ai(actor: CombatEntity) -> EncounterEvent:
	#1. can I attack?
	#   Yes - attack and return attack event
	var targets: Array = []
	var dirs = []
#	actor.abilities.shuffle()
#	for ability in actor.abilities:
#		var ability_targets: Array = cur_state.find_valid_targets(actor.entity_index, ability) #TODO
#		if ability_targets.size() > 0:
#			ability_targets.shuffle()
#			var atarget = ability_targets[0]
#			return use_ability(actor, atarget, ability)
		
	current_time = actor.time_spent
	cardinal.shuffle()
	diagonal.shuffle()
	dirs.append_array(cardinal)
	dirs.append_array(diagonal)
	for d in dirs:
		var neighbor = actor.location + d
		if !Constants.MAP_BOUNDARIES.has_point(neighbor):
#		 || !map.is_passable(neighbor):
			continue
#		if(neighbor.y < 0):
#			pass
		var target = cur_state.lookup_actor(neighbor)
		if target and target.faction != actor.faction:
			targets.push_back(target)
	if targets.size() > 0:
		targets.shuffle()
		var target = targets[0]
		return attack_roll(actor, target)
	#2. TODO can I use a different ability?
	#3. Approach closest target (breadth-first search)
	else:
		return gen_move(actor)



static func update(state: EncounterState, event: EncounterEvent) -> EncounterEvent:
	match event.kind:
		EncounterEvent.EventKind.Move:
			state.set_location(event.actor_idx, event.target_location)
		EncounterEvent.EventKind.Attack:
			state.resolve_attack(event.actor_idx, event.target_idx, event.damage)
			var target = state.actors[event.target_idx]
			if !target.is_alive():
				return EncEvent.death_event(event.timestamp, target)
		EncounterEvent.EventKind.Death:
			state.remove_actor(event.actor_idx)
	return null


const max_dist = 10
func breadth_first_search(start: Vector2, friendly_faction: int) -> Vector2:
	var dist: int = 1
	var frontier = [start]
	var visited: Dictionary = {}
	var breadcrumbs: Dictionary = {}
	var found_target = null
	while dist < max_dist \
		and frontier.size() > 0 \
		and found_target == null:
		var next_frontier = []
		dist += 1
		for here in frontier:
			if visited.has(here): continue
			visited[here] = true
			var target = cur_state.lookup_actor(here)
			if target != null and target.faction != friendly_faction:
				found_target = here
				break;
			var directions = []
			cardinal.shuffle()
			diagonal.shuffle()
			directions.append_array(cardinal)
			directions.append_array(diagonal)
			for direction in directions:
				var neighbor = here + direction
				# TODO: check if valid move
				# eg: out of bounds or in wall or occupied
				# at the start, target will always be non-null (will contain self)
				# for non-start here, target is guaranteed to be friendly at this point
				if target != null && here != start:
					assert(target.faction == friendly_faction)
					continue
				if !breadcrumbs.has(neighbor):
					breadcrumbs[neighbor] = here
					next_frontier.append(neighbor)
		frontier = next_frontier
	if found_target == null:
		return Vector2.ZERO
	var cursor = found_target
	while true:
		var previous = breadcrumbs.get(cursor, null)
		if previous == null:
			push_error("WHAAT")
			return Vector2.ZERO
		if previous == start:
			return cursor
		cursor = previous
	return Vector2.ZERO



func event_text(evt: EncounterEvent) -> String:
	match evt.kind:
		EncounterEvent.EventKind.Attack:
			return "{time}: {a} attacked {t}! {d} damage!".format(evt.dict())
		EncounterEvent.EventKind.Death:
			return "{time}: {a} died!".format(evt.dict())
		EncounterEvent.EventKind.Move:
			return "{time}: {a} moved! -> {loc}".format(evt.dict())
	push_warning("Event not handled by logger! {0}".format([evt.kind]))
	return ""


func gen_move(actor: CombatEntity) -> EncounterEvent:
	var move_to = breadth_first_search(actor.location, actor.faction)
	if move_to != Vector2.ZERO:
		return EncEvent.move_event(current_time, actor, move_to)
	#move randomly
	else:
		var dir = dirs[randi() % dirs.size()] # TODO track random state
		move_to = actor.location + dir
	return EncEvent.move_event(current_time, actor, move_to)

func attack_roll(actor: CombatEntity, target: CombatEntity) -> EncounterEvent:
	if randf() < actor.chance_to_hit_other(target): # TODO track random state
		var damage_range = actor.basic_attack_damage_to_other(target)
		var damage = rand_range(damage_range[0], damage_range[1]) # TODO track random state
		return EncEvent.attack_event(current_time, actor, target, damage)
	else:
		return EncEvent.miss_event(current_time, actor, target)

func use_ability(actor: CombatEntity, target: Vector2, ability: Ability) -> EncounterEvent:
	return EncEvent.ability_event(current_time, actor, ability, target)
