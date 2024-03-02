extends Resource

class_name EncounterDriver

var queue: PriorityQueue
var cur_state: EncounterState
const dirs: Array = [Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1)]

func initialize():
	cur_state = EncounterState.new()
	
	cur_state.enemies = []
	var nme = CombatEntity.new()
	nme.initialize(10, 10, 10, 10, 10, 10, Constants.ENEMY_FACTION)
	nme.entity_index = 0
	cur_state.actors.push_back(nme)
	
	cur_state.player = CombatEntity.new()
	cur_state.player.initialize(10, 10, 10, 10, 10, 10, Constants.PLAYER_FACTION)
	cur_state.player.entity_index = 1
	cur_state.actors.push_back(cur_state.player)
	
	queue.insert(cur_state.player, 0)
	queue.insert(nme, 0)

func tick() -> bool:
	# 0. is the player alive?
	if cur_state.player.cur_hp <= 0:
		return false
	# 1. grab the first thing in the priority queue
	var actor: CombatEntity = queue.pop_front()
	# 2. run its AI
	#    AI produces an EncounterEvent
	var evt: EncounterEvent = tick_ai(actor)
	# 3. record that event into a log
	# 4. call data_util.update on event and cur state to get next state
	# 5. If actor is still alive, re-insert it into the priority queue
	return true

func tick_ai(actor: CombatEntity) -> EncounterEvent:
	#1. can I attack?
	#   Yes - attack and return attack event
	var targets: Array = []
	for d in dirs:
		var neighbor = actor.location + d
		var target = cur_state.map.get(neighbor, false)
		if target and target.faction != actor.faction:
			targets.push_back(target)
	if targets.size() > 0:
		targets.shuffle() # TODO track random state
		var target = targets[0]
		return attack_event(actor, target)
	#2. TODO can I use a different ability?
	#3. Approach closest target (breadth-first search)
	else:
		return move_event(actor)

func attack_event(actor: CombatEntity, target: CombatEntity) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.kind = EncounterEvent.EventKind.Attack
	evt.actor_idx = actor.entity_index
	evt.target_idx = actor.entity_index
	if randf() < actor.chance_to_hit_other(target): # TODO track random state
		var damage_range = actor.basic_attack_damage_to_other(target)
		evt.did_hit = true
		evt.damage = rand_range(damage_range[0], damage_range[1]) # TODO track random state
	else:
		evt.did_hit = false
		evt.damage = 0
	return evt

func move_event(actor: CombatEntity) -> EncounterEvent:
	var evt = EncounterEvent.new()
	evt.kind = EncounterEvent.EventKind.Move
	# search for closest target
	var candidates = []	
	for search_distance in range(1, 10):
		for direction in dirs:
			var loc = search_distance * direction
			var candidate = cur_state.map.get(loc, false)
			if candidate:
				candidates.push_back(candidate)
	# move towards candidate
	if candidates.size() > 0:
		candidates.shuffle() # TODO track random state
		var candidate: CombatEntity = candidates[0]
		evt.target_location = candidate.location
	#move randomly
	else:
		var dir = dirs[randi() % dirs.size()] # TODO track random state
		evt.target_location = actor.location + dir
	return evt
