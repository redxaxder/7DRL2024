extends Resource

class_name EncounterDriver

var queue: PriorityQueue
var cur_state: EncounterState
const dirs: Array = [Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1)]
var history: EncounterHistory
var cur_idx: int = 0


func initialize():
	queue = PriorityQueue.new()
	cur_state = EncounterState.new()
	history = EncounterHistory.new()
	
	cur_state.actors = []
	
	var player = CombatEntity.new()
	player.initialize(10, 10, 10, 10, 10, 10, Constants.PLAYER_FACTION)
	player.actor_type = Actor.Type.Player
	insert_entity(player, Vector2(1, 1))
	
	for i in range(3):
		var nme = create_enemy()
		insert_entity(nme, Vector2(randi() % 5 + 5, randi() % 10))
	
	
func create_enemy() -> CombatEntity:
	var nme = CombatEntity.new()
	var reference_nme_idx = randi() % (Actor.Type.size() - 1) + 1
	nme.initialize_with_block(Actor.get_stat_block(reference_nme_idx), Constants.ENEMY_FACTION)	
	nme.actor_type = Actor.get_type(reference_nme_idx)
	return nme

func insert_entity(e: CombatEntity, loc: Vector2):
	e.entity_index = cur_idx
	cur_state.actors.push_back(e)
	cur_state.set_location(cur_idx, loc)
	queue.insert(e, 0)
	cur_idx += 1


func tick() -> bool:
	# 0. is the player alive?
	if cur_state.get_player().cur_hp <= 0:
		return false
	# 1. grab the first thing in the priority queue
	var actor: CombatEntity = queue.pop_front()
	# 2. run its AI
	#    AI produces an EncounterEvent
	var evt: EncounterEvent = tick_ai(actor)
	# 3. record that event into a log
	assert(evt is EncounterEvent)
	history.add_event(evt)
		
	# 4. call data_util.update on event and cur state to get next state
	history.add_state(DataUtil.dup_state(cur_state))
# warning-ignore:return_value_discarded
	DataUtil.update(cur_state, evt)
	# 5. If actor is still alive, re-insert it into the priority queue
	actor.time_spent += int(100.0 / float(actor.stats.speed()))
	queue.insert(actor, actor.time_spent)
	
	return true

func tick_ai(actor: CombatEntity) -> EncounterEvent:
	#1. can I attack?
	#   Yes - attack and return attack event
	var targets: Array = []
	for d in dirs:
		var neighbor = actor.location + d
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



const max_dist = 10
func breadth_first_search(start: Vector2, friendly_faction: int) -> Vector2:
	var dist: int = 1
	var frontier = [start]
	var visited: Dictionary = {}
	var directions = dirs.duplicate()
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
			directions.shuffle()
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
			return "{0} attacked {1}! {2} damage!".format([evt.actor_idx, evt.target_idx, evt.damage])
		EncounterEvent.EventKind.Move:
			return "{0} moved! -> {1}".format([evt.actor_idx, evt.target_location])
	push_warning("Event not handled by logger! {0}".format([evt.kind]))
	return ""


func gen_move(actor: CombatEntity) -> EncounterEvent:
	var move_to = breadth_first_search(actor.location, actor.faction)
	if move_to != Vector2.ZERO:
		return move_event(actor, move_to)
	#move randomly
	else:
		var dir = dirs[randi() % dirs.size()] # TODO track random state
		move_to = actor.location + dir
	return move_event(actor, move_to)

func attack_roll(actor: CombatEntity, target: CombatEntity) -> EncounterEvent:
	var did_hit
	var damage
	if randf() < actor.chance_to_hit_other(target): # TODO track random state
		var damage_range = actor.basic_attack_damage_to_other(target)
		did_hit = true
		damage = rand_range(damage_range[0], damage_range[1]) # TODO track random state
	else:
		did_hit = false
		damage = 0
	return attack_event(actor, target, did_hit, damage)





# Minimal constructors for events
func move_event(actor: CombatEntity, move_to: Vector2) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	assert(evt is EncounterEvent)
	evt.kind = EncounterEvent.EventKind.Move
	evt.actor_idx = actor.entity_index
	evt.target_location = move_to
	return evt

func attack_event(actor: CombatEntity, target: CombatEntity, did_hit, damage) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.set_script(preload("res://data/encounter/EncounterEvent.gd"))
	assert(evt is EncounterEvent)
	evt.kind = EncounterEvent.EventKind.Attack
	evt.actor_idx = actor.entity_index
	evt.target_idx = target.entity_index
	evt.damage = damage
	evt.did_hit = did_hit
	return evt
