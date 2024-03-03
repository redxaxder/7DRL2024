extends Resource

class_name EncounterDriver


var current_time = 0
var queue: PriorityQueue
var cur_state: EncounterState

const dirs: Array = [Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1)]
const cardinal: Array = [Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1)]
const diagonal: Array = [Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1), Vector2(1, -1)]
var history: EncounterHistory

var map: Map

var encounter_seed
func initialize(state: EncounterState, p_map: Map = null, use_seed: int = 0):
	if use_seed == 0:
		encounter_seed = randi()
	else:
		seed(use_seed)

	queue = PriorityQueue.new()
	history = EncounterHistory.new()
	
	cur_state = state
	map = p_map
	map.generate()
	
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
	actor.abilities.shuffle()
	for ability in actor.abilities:
		if ability.trigger_effect_kind == Ability.TriggerEffectKind.Activated:
			var atarget = cur_state.get_ability_target(actor.entity_index, ability)
			if atarget != Vector2.INF:
				return use_ability(actor, atarget, ability)
		
	current_time = actor.time_spent
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
			# check to see if the target has any abilities that respond to damage
			var response: EncounterEvent = trigger_damage_ability(state, event)
			if response != null:
				assert(event.timestamp > 0)
				assert(response.timestamp > 0)
				return response
		EncounterEvent.EventKind.Death:
			state.remove_actor(event.actor_idx)
		EncounterEvent.EventKind.AbilityActivation:
			handle_ability_activation(state, event)
	return null
	
static func handle_ability_activation(state: EncounterState, event: EncounterEvent):
	var ability = event.ability
	match ability.effect_kind:
		Ability.AbilityEffectKind.Damage:
			var target = state.lookup_actor(event.target_location)
			if target != null:
				state.resolve_attack(event.actor_idx, target.entity_index, ability.power)
				if !target.is_alive():
					return EncEvent.death_event(event.timestamp, target)

static func trigger_damage_ability(state: EncounterState, event: EncounterEvent) -> EncounterEvent:
	if event.damage > 0:
		var responder: CombatEntity = state.actors[event.target_idx]
		for ab in responder.abilities:
			if ab.trigger_effect_kind == Ability.TriggerEffectKind.Damage && ab.trigger_target_kind == Ability.TargetKind.Self:
				var atarget = state.get_ability_target(responder.entity_index, ab)
				if atarget != Vector2.INF:
					return EncEvent.ability_event(event.timestamp, responder, ab, atarget)
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
