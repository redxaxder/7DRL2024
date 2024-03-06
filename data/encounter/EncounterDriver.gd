extends Resource

class_name EncounterDriver


var current_time = 0
var queue: PriorityQueue
var cur_state: EncounterState

const REACTION_DELAY = 1 # maybe parameterize this by ability later
const dirs: Array = [Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1)]
const cardinal: Array = [Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1)]
const diagonal: Array = [Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1), Vector2(1, -1)]
var history: EncounterHistory

var map: Map

var encounter_seed

var rng: int

func use_seeded_rng():
	seed(rng)
	rng = randi()

func initialize(state: EncounterState, p_map: Map = null, use_seed: int = 0):
	if use_seed == 0:
		encounter_seed = randi()
	else:
		seed(use_seed)
	rng = randi()

	queue = PriorityQueue.new()
	history = EncounterHistory.new()
	
	cur_state = state
	map = p_map
	
	for actor in cur_state.actors:
		queue.insert(actor, actor.time_spent)
	
	history.add_state(DataUtil.deep_dup(cur_state))


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

	# 1. grab the first thing in the priority queue
	var next_up = queue.pop_front()
	var events = []
	var actor = null
	if next_up is Reaction:
		assert(next_up.trigger_time >= current_time, "time only flows in one direction")
		current_time = next_up.trigger_time 
		events = fire_reaction(next_up)
	else:
		actor = next_up
		if !actor.is_alive():
			return true
		assert(actor.time_spent >= current_time, "time only flows in one direction")
		current_time = actor.time_spent
		events = tick_ai(actor)

	# 3. record that event, run it, and run events it triggers
	var reactions_to_prepare = []
	while events.size() > 0:
		var evt = events.pop_front()
		assert(evt != null)
		assert(typeof(evt) != TYPE_ARRAY)
		if evt.kind == EncounterEventKind.Kind.PrepareReaction:
			reactions_to_prepare.append(evt)
		history.add_event(evt)
		var triggered_events = EncounterCore.update(cur_state, evt)
		for r in triggered_events:
			assert(r != null)
			assert(typeof(r) != TYPE_ARRAY)
		history.add_state(DataUtil.deep_dup(cur_state))
		triggered_events.shuffle()
		events.append_array(triggered_events)
	reactions_to_prepare.shuffle()
	for _reaction in reactions_to_prepare:
		var evt: EncounterEvent = _reaction
		var reaction = Reaction.new()
		reaction.ability = evt.ability
		reaction.trigger_time = evt.timestamp + REACTION_DELAY
		reaction.actor_idx = evt.actor_idx
		reaction.target_idx = evt.target_idx
		reaction.target_location = evt.target_location
		queue.insert(reaction, reaction.trigger_time)

	# 5. If actor is still alive, re-insert it into the priority queue
	# if we got here after handling a reaction, the actor is null and we do not reinsert anything
	if actor != null:
		actor.pass_time(int(100.0 / float(actor.stats.speed())))
		queue.insert(actor, actor.time_spent)
	
	return true

class Reaction extends Resource:
	var trigger_time: int = -1
	var ability: Ability = null
	var actor_idx: int = -1
	var target_idx: int = -1
	var target_location: Vector2 = Vector2.INF

func fire_reaction(reaction: Reaction) -> Array:
	use_seeded_rng()
	var target = reaction.target_location
	var actor: CombatEntity = cur_state.actors[reaction.actor_idx]
	var ability = reaction.ability
	if ability.activation.trigger_aim == SkillsCore.TriggerAim.Random:
		target = EncounterCore.get_ability_target(cur_state, actor, ability)
	elif reaction.target_idx >= 0:
		var target_actor: CombatEntity = cur_state.actors[reaction.target_idx]
		target = target_actor.location
	if target == Vector2.INF: return []
	#TODO: this should fail if the target is invalid
	# ie: wrong faction or missing or something
	return EncounterCore.use_ability(actor, target, ability, current_time)

func tick_ai(actor: CombatEntity) -> Array: # EncounterEvent
	#1. can I attack?
	#   Yes - attack and return attack event
	var targets: Array = []
	var dirs = []
	use_seeded_rng()
	actor.actions.shuffle()
	for ability in actor.actions:
		assert(ability.activation.trigger == SkillsCore.Trigger.Action)
		var atarget = EncounterCore.get_ability_target(cur_state, actor, ability)
		if atarget == Vector2.INF: continue
		var ab_evt = EncounterCore.use_ability(actor, atarget, ability, current_time)
		if ab_evt.size() > 0: 
			return ab_evt
		
	cardinal.shuffle()
	diagonal.shuffle()
	dirs.append_array(cardinal)
	dirs.append_array(diagonal)
	for d in dirs:
		var neighbor = actor.location + d
		if !Constants.MAP_BOUNDARIES.has_point(neighbor):
			continue
		var target = cur_state.lookup_actor(neighbor)
		if target and target.faction != actor.faction:
			targets.push_back(target)
	if targets.size() > 0:
		targets.shuffle()
		var target = targets[0]
		return [attack_roll(actor, target)]
	#2. TODO can I use a different ability?
	#3. Approach closest target (breadth-first search)
	else:
		return [gen_move(actor)]


const max_dist = 50
func breadth_first_search(start: Vector2, friendly_faction: int) -> Vector2:
	use_seeded_rng()
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
				if !breadcrumbs.has(neighbor) && map.can_move(neighbor):
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

func gen_move(actor: CombatEntity) -> EncounterEvent:
	var move_to = breadth_first_search(actor.location, actor.faction)
	if move_to != Vector2.ZERO && !cur_state.is_occupied(move_to):
#		if map.get(move_to, null) != null:
#			pass
		return EncEvent.move_event(current_time, actor, move_to)
	#move randomly
	else:
		move_to = actor.location
		dirs.shuffle()
		for dir in dirs:
			var candidate = actor.location + dir
			if map.can_move(candidate) && !cur_state.is_occupied(candidate):
				move_to = candidate
				break
	return EncEvent.move_event(current_time, actor, move_to)

func attack_roll(actor: CombatEntity, target: CombatEntity) -> EncounterEvent:
	use_seeded_rng()
	if randf() < actor.chance_to_hit_other(target): # TODO track random state
		var damage_range = actor.basic_attack_damage_to_other(target)
		var damage = rand_range(damage_range[0], damage_range[1]) # TODO track random state
		return EncEvent.attack_event(current_time, actor, target, damage, actor.element)
	else:
		return EncEvent.miss_event(current_time, actor, target)
