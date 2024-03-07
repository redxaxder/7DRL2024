extends Node2D


export var show_extra_history:bool = true setget set_show_extra_history
func set_show_extra_history(x):
	show_extra_history = x
	var h = get_node_or_null("%history_view")
	if h:
		h.show_extra_history = show_extra_history

const time_limit = 1000


var player_stats: StatBlock
var player_hp: int = 20
var progress: int = 1

var skill_tree: SkillTree

var driver_seed: int
var current_encounter_seed: int
var next_encounter_base_state: EncounterState # without player buffs applied
var next_encounter_map: Map
var next_encounter_outcome: EncounterHistory

# are we waiting for the player to decide to do an encounter, (true) or
# are we in the history view (false)?
var gonogo: bool = false
var gameover: bool = false
var has_seen_end: bool = false
var map = Map.new()

func _ready():
# warning-ignore:return_value_discarded
	get_node("%GO").connect("pressed",self,"go")
# warning-ignore:return_value_discarded
	get_node("%DONE").connect("pressed",self,"done")
# warning-ignore:return_value_discarded
	get_node("%RESTART").connect("pressed",self,"restart")
# warning-ignore:return_value_discarded
	get_node("%history_view").connect("updated", self, "history_scroll")
# warning-ignore:return_value_discarded
	get_node("%history_view").connect("seen_end", self, "seen_end")
# warning-ignore:return_value_discarded
	get_node("%CloseButton").connect("pressed", self, "toggle_skill_tree")
# warning-ignore:return_value_discarded
	get_node("%OpenSkillTree").connect("pressed", self, "toggle_skill_tree")
# warning-ignore:return_value_discarded
	get_node("%state_view").connect("actor_hovered", get_node("%actor_info"), "set_actor")
# warning-ignore:return_value_discarded
	get_node("%ConsumablesContainer").connect("consume_teleport", self, "no_go")
# warning-ignore:return_value_discarded
	get_node("%ConsumablesContainer").connect("consume_health", self, "consume_health_potion")
	#TODO: get rewards vs no rewards in teleport
# warning-ignore:return_value_discarded
	get_node("%ConsumablesContainer").connect("consume_invisibility", self, "sneak")
	get_node("%history_view").show_extra_history = show_extra_history
	get_node("%ViewSkillTree").connect("skill_unlocked",self,"update_skill_points")
	
	new_game()
	
	var timer : Timer = get_node("%ConsumablesCounter")
	timer.start(0.5)
# warning-ignore:return_value_discarded
	timer.connect("timeout", self, "transfer_reward")

func update_skill_points():
	get_node("%ViewSkillTree").update_num_skills_to_unlock(progress)
	get_node("%SkillPoints").text = "Skill Points: "+str(get_node("%ViewSkillTree").num_skills_to_unlock)

func transfer_reward():
	if gonogo && !gameover:
		get_node("%ConsumablesContainer").transfer_reward()

func consume_health_potion():
	var max_hp = player_stats.max_hp()
	player_hp = int(min(
		max_hp,
		player_hp + get_node("%ConsumablesContainer").health_potion_amount
	))
	make_encounter(current_encounter_seed)

func new_game():
	gameover = false

	skill_tree = SkillTree.new()
	skill_tree.hand_rolled_skill_tree()
	get_node("%ViewSkillTree").set_skills(skill_tree)
	player_stats = Actor.get_stat_block(Actor.Type.Player)
	player_hp = player_stats.max_hp()
	progress = 0

	get_node("%ViewSkillTree").player_stats = player_stats
	randomize()
	get_node("%ConsumablesContainer").init_starting_consumables()
	make_encounter()


func history_scroll(s: EncounterState, what: EncounterEvent):
	get_node("%state_view").update_view(s, what)


func seen_end():
	has_seen_end = true
	update_button_visibility()
	
func update_button_visibility():
	get_node("%DONE").visible = !gonogo and !gameover and has_seen_end
	get_node("%GO").visible = gonogo and !gameover
	get_node("%RESTART").visible = gameover
	get_node("%ConsumablesContainer").visible = gonogo and !gameover and !$SkillTreePanel.visible
	get_node("%FloorNumber").visible = gonogo and !$SkillTreePanel.visible
	get_node("%SkillPoints").visible = gonogo

func apply_player_mods(s: EncounterState) -> EncounterState:
	var st = DataUtil.deep_dup(s)
	var player: CombatEntity = st.get_player()
	player.stats = DataUtil.deep_dup(player_stats)
	for skill in skill_tree.unlocks:
		if skill.kind == Skill.Kind.Ability:
			player.append_ability(skill.ability)
	return st


func go():
	var final_player_state = next_encounter_outcome.final().get_player()
	var remaining_hp = final_player_state.cur_hp
	# todo: pass in extra log messages if player is alive
	
	var example_messages = [
		"lorem",
		"ipsum",
		"dolore",
	]
	get_node("%history_view").view(next_encounter_outcome, map, example_messages)
	gonogo = false
	update_button_visibility()

func no_go():
	make_encounter()

func calculate_new_hp() -> int:
	var final_player_state = next_encounter_outcome.final().get_player()
	var remaining_hp = final_player_state.cur_hp
	var temp_hp = final_player_state.stats.max_hp() - player_stats.max_hp()
	temp_hp = min(temp_hp, remaining_hp - 1)
	temp_hp = max(0, temp_hp)
	return remaining_hp - temp_hp

func done():
	# apply encounter consequences
	player_hp = calculate_new_hp()
	if player_hp > 0:
		get_node("%ConsumablesContainer").win_rewards()
		make_encounter()
	else:
		gameover = true
		update_button_visibility()
		
func sneak():
	get_node("%ConsumablesContainer").win_rewards()
	no_go()

func restart():
	new_game()

func make_encounter(use_seed: int = 0):
	progress += 1
	has_seen_end = false
	update_skill_points()
	get_node("%FloorNumber").text = "Floor: " + str(progress)
	var encounter_seed = use_seed
	if encounter_seed == 0:
		encounter_seed = randi()
	prints("encounter seed", encounter_seed)

	seed(encounter_seed)
	current_encounter_seed = encounter_seed
	driver_seed = randi()

	get_node("%history_view").clear()
	map.generate()
	
	var passable = map.list_passable()
	passable.shuffle()

	get_node("%ConsumablesContainer").init_rewards()

	var state = EncounterState.new()
	var player = CombatEntity.new()
	player.initialize_with_block(player_stats, Constants.PLAYER_FACTION, "You")
	player.actor_type = Actor.Type.Player
	assert(player_hp > 0)
	player.cur_hp = player_hp
	state.add_actor(player, passable.pop_back().loc)
	
	var spawns = min(randi() % 2, randi() % 5) + 1
	for _i in spawns:
		#TODO: maybe get harder spawns more often with high progress
		var spawn_category = roll_weighted_table([0.5,0.3, 0.2])
		var spawn_class
		match spawn_category:
			0: spawn_class = Actor.SPAWN_EASY
			1: spawn_class = Actor.SPAWN_MEDIUM
			2: spawn_class = Actor.SPAWN_HARD
		var spawn = spawn_class[randi() % spawn_class.size() - 1]
		state.add_actor(Actor.create_unit(spawn, Constants.ENEMY_FACTION), passable.pop_back().loc)

	var max_shrines = 1 + int(progress / 5)
	var num_shrines = min(randi() % (max_shrines + 1),randi() % (max_shrines + 1))
	for _i in num_shrines:
		var shrine_stat = randi() % Stat.Kind.MAX
		state.add_actor(Actor.create_shrine(shrine_stat), passable.pop_back().loc)
	
	next_encounter_base_state = state
	gonogo = true
	update_button_visibility()
	get_node("%state_view").init_view(apply_player_mods(next_encounter_base_state), map)
	update_preview()
	update_outcome()

func roll_weighted_table(table: Array) -> int:
	var roll = randf()
	var accum = 0
	var i = 0
	var n = table.size() - 1
	while i < n:
		accum += table[i]
		if roll < accum:
			return i
		i += 1
	return n


func update_preview():
	get_node("%state_view").update_view(apply_player_mods(next_encounter_base_state))

func toggle_skill_tree():
	$SkillTreePanel.visible = !$SkillTreePanel.visible
	
	update_button_visibility()
	update_preview()
	update_outcome()

func update_outcome():
	var mod_state = apply_player_mods(next_encounter_base_state)
	next_encounter_outcome = drive_encounter(mod_state, map, driver_seed)
	var encounter_damage = player_hp - calculate_new_hp()
	get_node("%damage_preview").text = "[ - %d ]" % encounter_damage
	
static func drive_encounter(mod_state: EncounterState, m: Map, ds: int) -> EncounterHistory:
	var driver = EncounterDriver.new()
	driver.initialize(mod_state, m, ds)
	while driver.tick() and driver.current_time < time_limit:
		pass
	return driver.history
