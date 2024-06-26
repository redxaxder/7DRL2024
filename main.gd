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
var driver: EncounterDriver = null
var current_encounter_seed: int
var next_encounter_base_state: EncounterState # without player buffs applied
var next_encounter_map: Map
var encounter_result: EncounterState

var reward_bonuses = []

# are we waiting for the player to decide to do an encounter, (true) or
# are we in the history view (false)?
#var gonogo: bool = false
#var gameover: bool = true
var has_seen_end: bool = false
var map = Map.new()

enum ui_modes {GONOGO, VIEW, TITLE, DEFEAT}
var ui_mode = ui_modes.TITLE

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
# warning-ignore:return_value_discarded
	get_node("%ViewSkillTree").connect("skill_unlocked",self,"update_skill_points")
	
	
	
	var title = get_node("%Title")
	title.connect("select", self, "title_select")
	var meta = load_meta()
	meta.unlock_today()
	meta.save()
	refresh_title_list()
	title.pick_something()
	update_button_visibility()
	var timer : Timer = get_node("%ConsumablesCounter")
	timer.start(0.5)
	if(Constants.debug_mode):
		get_node("%damage_preview").visible = true
# warning-ignore:return_value_discarded
	timer.connect("timeout", self, "transfer_reward")
	if meta.is_fresh:
		meta.is_fresh = false
		meta.save()
		new_game()
	

func refresh_title_list():
	var title = get_node("%Title")
	var meta = load_meta()
	title.clear_unlocks()
	var unlocked = meta.get_unlocked()
	if unlocked.size() > 2: 	#add duplicate of today to top of list
		var today = meta.get_date_index()
		title.add_unlocked_line(today, meta.did_win(today))
	for i in unlocked:
		if selected < 0: selected = i
		title.add_unlocked_line(i, meta.did_win(i))
	



var selected = -1
func title_select(i: int):
	selected = i
	

func _process(delta):
	if driver == null: return
	var encounter_damage = calculate_damage(driver.cur_state)
	if driver.started and !driver.done:
		get_node("%damage_preview").text = "[ ... -%d ]" % encounter_damage
		for _i in 5:
			if !driver.tick(): break
	elif driver != null:
		get_node("%damage_preview").text = "[ - %d ]" % encounter_damage


func update_skill_points():
	get_node("%ViewSkillTree").update_num_skills_to_unlock(progress)
	var next_skill_point_string = ""
	
	var next_skill_point = get_node("%ViewSkillTree").next_skill_point(progress)
	if next_skill_point:
		next_skill_point_string = " (next: Floor {0})".format([next_skill_point])
	get_node("%SkillPoints").text = "Skill Points: {0}{1}".format([
		get_node("%ViewSkillTree").num_skills_to_unlock,
		next_skill_point_string
	])

func transfer_reward():
	if ui_mode == ui_modes.GONOGO:
		get_node("%ConsumablesContainer").transfer_reward()

func consume_health_potion():
	var max_hp = player_stats.max_hp()
	player_hp = max_hp
	update_outcome()

func new_game():
	ui_mode = ui_modes.GONOGO
	
	# set lethal encounter to random floor 1-3
	
	reward_bonuses = []
	get_node("%ViewSkillTree").set_reward_bonuses(reward_bonuses)

	skill_tree = SkillTree.new()
#	skill_tree.hand_rolled_skill_tree()
	skill_tree.random_skill_tree(selected)

	
	get_node("%ViewSkillTree").set_skills(skill_tree)
	player_stats = Actor.get_stat_block(Actor.Type.Player)
	get_node("%ViewSkillTree").update_stats(player_stats)
	player_hp = player_stats.max_hp()
	progress = 0

	get_node("%ViewSkillTree").player_stats = player_stats
	randomize()
	encounters[1].focus = (randi() % 3) + 1
	get_node("%ConsumablesContainer").init_starting_consumables()
	make_encounter()
	update_button_visibility()
	


func history_scroll(s: EncounterState, what: EncounterEvent):
	get_node("%state_view").update_view(s, what)


func seen_end(result):
	has_seen_end = true
	encounter_result = result
	update_button_visibility()


func update_button_visibility():
	get_node("%DONE").visible = ui_mode == ui_modes.VIEW and has_seen_end
	get_node("%GO").visible = (ui_mode == ui_modes.GONOGO or ui_mode == ui_modes.TITLE) and !$SkillTreePanel.visible
	get_node("%RESTART").visible = ui_mode == ui_modes.DEFEAT
	get_node("%ConsumablesContainer").visible = ui_mode == ui_modes.GONOGO and !$SkillTreePanel.visible
	get_node("%FloorNumber").visible = ui_mode != ui_modes.TITLE and !$SkillTreePanel.visible
	get_node("%SkillPoints").visible = ui_mode == ui_modes.GONOGO or $SkillTreePanel.visible
	get_node("%OpenSkillTree").visible = ui_mode == ui_modes.GONOGO
	get_node("%Title").visible = ui_mode == ui_modes.TITLE

func apply_player_mods(s: EncounterState) -> EncounterState:
	var st = DataUtil.deep_dup(s)
	var player: CombatEntity = st.get_player()
	player.stats = DataUtil.deep_dup(player_stats)
	for skill in skill_tree.unlocks:
		if skill.kind == Skill.Kind.Ability:
			player.append_ability(skill.ability)
	return st


func go():
	if ui_mode == ui_modes.TITLE:
		new_game()
		ui_mode = ui_modes.GONOGO
		return
	var victory_text = []
	var Consumables =  get_node("ConsumablesContainer")
	victory_text.append("You won!")
	victory_text.append_array(Consumables.get_reward_messages())
	
	driver.tick()
	get_node("%state_view").init_view(driver.history.get_state(0), map)
	get_node("%history_view").view(driver.history, map, victory_text)
	ui_mode = ui_modes.VIEW
	update_button_visibility()

func no_go():
	make_encounter()


func _unhandled_input(event):
	if event.is_action_pressed("toggle"):
		if get_node("%GO").visible == true: go()
	if event.is_action_pressed("return") && !$SkillTreePanel.visible:
		if get_node("%GO").visible == true && ui_mode == ui_modes.GONOGO: 
			go()
		if get_node("%DONE").visible == true && ui_mode == ui_modes.VIEW:
			done()
	if event.is_action_pressed("teleport_potion"):
		get_node("%ConsumablesContainer").use_consumable("teleport")
	if event.is_action_pressed("health_potion"):
		get_node("%ConsumablesContainer").use_consumable("health")
	if event.is_action_pressed("invisibility_potion"):
		get_node("%ConsumablesContainer").use_consumable("invisibility")
		
	# DEBUG
	if(Constants.debug_mode):
		# z
		if event.is_action_pressed("jump_encounters"):
			progress += 9
			make_encounter()
		# x
		if event.is_action_pressed("increase_stats"):
			for i in 6:
				var bonus = Bonus.new()
				bonus.initialize_bonus(i, 10)
				reward_bonuses.append(bonus)
			get_node("%ViewSkillTree").set_reward_bonuses(reward_bonuses)
			get_node("%ViewSkillTree").recalculate_player_bonuses()
			update_outcome()

func calculate_damage(result_state: EncounterState) -> int:
	var player_state = result_state.get_player()
	var remaining_hp = player_state.cur_hp
	var temp_hp = player_state.stats.max_hp() - player_stats.max_hp()
	var max_tmp = max(0, remaining_hp - 1)
	temp_hp = clamp(temp_hp, 0, max_tmp)
	var final_hp = remaining_hp - temp_hp
	return player_hp - final_hp
	
func calculate_new_hp():
	return player_hp - calculate_damage(encounter_result)
	
func done():
	player_hp = calculate_new_hp();

	if player_hp > 0:
		win_rewards()
		make_encounter()
	else:
		ui_mode = ui_modes.DEFEAT
		get_node("%Title").set_victory(false)
		update_button_visibility()
		
func sneak():
	win_rewards()
	no_go()
	
func win_rewards():
	reward_bonuses.append_array(
		get_node("%ConsumablesContainer").win_rewards()
	)
	var prev_max_hp = player_stats.max_hp()
	get_node("%ViewSkillTree").set_reward_bonuses(reward_bonuses)
	get_node("%ViewSkillTree").recalculate_player_bonuses()
	var new_max_hp = player_stats.max_hp()
	player_hp = player_hp + new_max_hp - prev_max_hp

func restart():
	ui_mode = ui_modes.TITLE
	update_button_visibility()

func make_encounter(use_seed: int = 0):
	progress += 1
	if progress > 100:
		load_meta().win(selected).save()
		ui_mode = ui_modes.TITLE
		get_node("%Title").set_victory(true)
		get_node("%Title").mark_won(selected)
		update_button_visibility()
		return
	has_seen_end = false
	update_skill_points()
	get_node("%FloorNumber").text = "Floor: " + str(progress)
	var encounter_seed = use_seed
	if encounter_seed == 0:
		encounter_seed = randi()
#	prints("encounter seed", encounter_seed)

	seed(encounter_seed)
	current_encounter_seed = encounter_seed
	driver_seed = randi()

	get_node("%history_view").clear()
	map.generate()
	
	var passable = map.list_passable()
	passable.shuffle()

	if progress == 50:
		load_meta().unlock_random(randi()).save()
		refresh_title_list()

	get_node("%ConsumablesContainer").init_rewards(progress)

	var state = EncounterState.new()
	var player = CombatEntity.new()
	player.initialize_with_block(player_stats, Constants.PLAYER_FACTION, "You")
	player.actor_type = Actor.Type.Player
	assert(player_hp > 0)
	state.add_actor(player, passable.pop_back().loc)
	
	var weights = []
	weights.resize(encounters.size())
	for i in encounters.size():
		var dist: float = abs(encounters[i].focus - progress) / encounters[i].get("spread", DEFAULT_SPREAD)
		var w = encounters[i].get("weight",DEFAULT_WEIGHT) * exp(-1 * dist * dist)
		weights[i] = w
	var e = encounters[roll_weighted_table(weights)]
	var spawns = e.min + (randi() % (1 + e.max - e.min))
	for _i in spawns:
		if passable.size() == 0: break
		var spawn = e.units[randi() % e.units.size()]
		state.add_actor(Actor.create_unit(spawn, Constants.ENEMY_FACTION), passable.pop_back().loc)

	var max_shrines = int(progress / 8)
	var num_shrines = randi() % (max_shrines+1)
	for _i in num_shrines:
		if passable.size() == 0: break
		var shrine_stat = Actor.SHRINE_TYPES[randi() % Actor.SHRINE_TYPES.size()]
		var shrine = Actor.create_shrine(shrine_stat) if (randf() < 0.5) else \
					Actor.create_big_shrine(shrine_stat)
		state.add_actor(shrine, passable.pop_back().loc)
	
	next_encounter_base_state = state
	ui_mode = ui_modes.GONOGO
	update_button_visibility()
	get_node("%state_view").init_view(apply_player_mods(next_encounter_base_state), map)
	update_outcome()

const DEFAULT_WEIGHT = 100
const DEFAULT_SPREAD = 20
var WHOEVER: Array = [ \
	Actor.Type.Blorp, 
	Actor.Type.Snake,
	Actor.Type.Goblin,
	Actor.Type.Gazer,
	Actor.Type.Wolf,
	Actor.Type.Crab,
	Actor.Type.Goblin,
	Actor.Type.Squid,
	Actor.Type.Hermit,
	#dragon not included
	]
var encounters = [
	{	"weight": 100,
		"focus": 0, # the main floor it's on
		"min": 1,
		"max": 6,
		"units": [Actor.Type.Blorp]
	},
	{	"weight": 400000, # near guarantee of two wolves on floor 2
		"focus": 2, # changed in main
		"spread": 0.0000001,
		"min": 2,
		"max": 3,
		"units": [Actor.Type.Wolf, Actor.Type.Dragon]
	},
	{	"focus": 5, #very early game encounters
		"min": 2,
		"max": 4,
		"units": [Actor.Type.Blorp, Actor.Type.Snake, Actor.Type.Goblin, Actor.Type.Squid, Actor.Type.Hermit]
	},
	{	"focus": 10,
		"min": 1,
		"max": 2,
		"units": [Actor.Type.Wolf, Actor.Type.Imp]
	},
	{	"focus": 15,
		"min": 1,
		"max": 6,
		"units": [Actor.Type.Crab]
	},
	{	"focus": 30, # the main floor it's on
		"min": 1,
		"max": 6,
		"units": [Actor.Type.Blorp, Actor.Type.Snake, Actor.Type.Crab]
	},
	{   "weight": 200,
		"focus": 50,
		"min": 1,
		"max": 7,
		"units": [Actor.Type.Wolf]
	},
	{	"focus": 30,
		"spread": 50,
		"min": 1,
		"max": 5,
		"units": WHOEVER,
	},
	{	"focus": 40,
		"spread": 40,
		"min": 1,
		"max": 6,
		"units": [Actor.Type.Goblin]
	},
	{	"focus": 70,
		"spread": 50,
		"min": 3,
		"max": 8,
		"units": WHOEVER,
	},
	{	"focus": 80,
		"spread": 40,
		"min": 4,
		"max": 12,
		"units": [Actor.Type.Goblin]
	},
	{	"focus": 80,
		"min": 1,
		"max": 6,
		"units": [Actor.Type.Imp, Actor.Type.Gazer, Actor.Type.Gazer, Actor.Type.Crab, Actor.Type.Goblin]
	},
	{	"focus": 100,
		"min": 1,
		"max": 6,
		"units": [Actor.Type.Imp, Actor.Type.Gazer, Actor.Type.Dragon]
	},
]


func roll_weighted_table(table: Array) -> int:
	var total_weight = 0
	for t in table:
		total_weight += t
	var roll = randf() * total_weight
	var accum = 0
	var i = 0
	var n = table.size() - 1
	while i < n:
		accum += table[i]
		if roll < accum:
			return i
		i += 1
	return n



func toggle_skill_tree():
	$SkillTreePanel.visible = !$SkillTreePanel.visible
	update_button_visibility()
	update_outcome()

func update_outcome():
	player_hp = min(player_hp, player_stats.max_hp())
	var mod_state = apply_player_mods(next_encounter_base_state)
	mod_state.get_player().cur_hp = player_hp

	driver = EncounterDriver.new()
	get_node("%state_view").update_view(DataUtil.deep_dup(mod_state))
	driver.initialize(mod_state, map, driver_seed)
	driver.tick()
	
	
	
	


#func is_fresh() -> bool:
#	return load_meta().is_fresh

#func mark_unfresh():
#	var m = load_meta()
#	m.is_fresh = false
#	m.save()

func load_meta() -> Meta:
	var m = ResourceLoader.load(Meta.PATH)
	if m is Meta:
		return m
	else:
		return Meta.new()

func unlock_today():
	load_meta().unlock_today().save()
