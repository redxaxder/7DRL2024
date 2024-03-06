extends Node2D


export var show_extra_history:bool = true setget set_show_extra_history
func set_show_extra_history(x):
	show_extra_history = x
	var h = get_node_or_null("%history_view")
	if h:
		h.show_extra_history = show_extra_history

const time_limit = 3000


var player_stats: StatBlock
var player_hp: int = 20
var skill_tree: SkillTree
var skips = 50

var driver_seed: int
var current_encounter_seed: int
var next_encounter_base_state: EncounterState # without player buffs applied
var next_encounter_map: Map
var next_encounter_outcome: EncounterHistory

# are we waiting for the player to decide to do an encounter, (true) or
# are we in the history view (false)?
var gonogo: bool = false
var gameover: bool = false
var map = Map.new()

func _ready():
# warning-ignore:return_value_discarded
	get_node("%GO").connect("pressed",self,"go")
# warning-ignore:return_value_discarded
	get_node("%NOGO").connect("pressed",self,"no_go")
# warning-ignore:return_value_discarded
	get_node("%DONE").connect("pressed",self,"done")
# warning-ignore:return_value_discarded
	get_node("%RESTART").connect("pressed",self,"restart")
# warning-ignore:return_value_discarded
	get_node("%history_view").connect("updated", self, "history_scroll")
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
	get_node("%ConsumablesContainer").connect("consume_invisibility", self, "no_go")
	get_node("%history_view").show_extra_history = show_extra_history
	new_game()

func consume_health_potion():
	player_hp += get_node("%ConsumablesContainer").health_potion_amount
	make_encounter(current_encounter_seed)

func new_game():
	gameover = false

	skill_tree = SkillTree.new()
	skill_tree.hand_rolled_skill_tree()
	get_node("%ViewSkillTree").set_skills(skill_tree)
	player_stats = Actor.get_stat_block(Actor.Type.Player)
	player_hp = 20

	get_node("%ViewSkillTree").player_stats = player_stats
	randomize()
	make_encounter()


func history_scroll(s: EncounterState, what: EncounterEvent):
	get_node("%state_view").update_view(s, what)


func update_button_visibility():
	get_node("%DONE").visible = !gonogo and !gameover
	get_node("%GO").visible = gonogo and !gameover
	get_node("%NOGO").visible = gonogo and !gameover and skips > 0
	get_node("%RESTART").visible = gameover
	get_node("%ConsumablesContainer").visible = gonogo and !gameover and !$SkillTreePanel.visible

func apply_player_mods(s: EncounterState) -> EncounterState:
	var st = DataUtil.deep_dup(s)
	var player: CombatEntity = st.get_player()
	player.stats = DataUtil.deep_dup(player_stats)
	for skill in skill_tree.unlocks:
		if skill.kind == Skill.Kind.Ability:
			player.append_ability(skill.ability)
	return st


func go():
	get_node("%history_view").view(next_encounter_outcome, map)
	gonogo = false
	update_button_visibility()

func no_go():
	skips -= 1
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
		make_encounter()
	else:
		gameover = true
		update_button_visibility()

func restart():
	new_game()

func make_encounter(use_seed: int = 0):
	var encounter_seed = use_seed
	if encounter_seed == 0:
		encounter_seed = randi()
	prints("encounter seed", encounter_seed)

	seed(encounter_seed)
	current_encounter_seed = encounter_seed
	driver_seed = randi()

	get_node("%history_view").clear()
	map.generate()

	var state = EncounterState.new()
	var player = CombatEntity.new()
	player.initialize_with_block(player_stats, Constants.PLAYER_FACTION, "You")
	player.actor_type = Actor.Type.Player
	assert(player_hp > 0)
	player.cur_hp = player_hp
	state.add_actor(player, map.random_passable_tile(state).loc)
	

	for _i in range(randi() % 3 + 1):
		var nme = create_enemy()
		state.add_actor(nme, map.random_passable_tile(state).loc)
		
	var shrine = Actor.create_shrine(Stat.Kind.Brains)
	state.add_actor(shrine, map.random_passable_tile(state).loc)
	
	next_encounter_base_state = state
	gonogo = true
	update_button_visibility()
	get_node("%state_view").init_view(apply_player_mods(next_encounter_base_state), map)
	update_preview()
	update_outcome()


func create_enemy() -> CombatEntity:
	var nme = CombatEntity.new()
	var a = Actor.new()
	var reference_nme_type = randi() % (Actor.Type.size() - 1) + 1
	nme.initialize_with_block(Actor.get_stat_block(reference_nme_type), Constants.ENEMY_FACTION, Actor.get_name(reference_nme_type))	
	nme.actor_type = reference_nme_type
	nme.element = a.get_element(reference_nme_type)
	return nme

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
