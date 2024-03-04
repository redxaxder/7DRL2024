extends Node2D

var player_stats: StatBlock
var player_hp: int = 20
var skill_tree: SkillTree
var skips = 50
var driver: EncounterDriver

const turn_limit = 500

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
	new_game()


func new_game():
	gameover = false
	randomize()

	skill_tree = SkillTree.new()
	skill_tree.hand_rolled_skill_tree()
	get_node("%ViewSkillTree").set_skills(skill_tree)
	player_stats = StatBlock.new()
	var s = Actor.STAT_BLOCKS[Actor.Type.Player]
	player_stats.initialize(s[0],s[1],s[2],s[3],s[4],s[5])
	player_hp = 20
	make_encounter(1234)


func history_scroll(s: EncounterState, what: EncounterEvent):
	get_node("%state_view").update_view(s, what)


func update_button_visibility():
	get_node("%DONE").visible = !gonogo and !gameover
	get_node("%GO").visible = gonogo and !gameover
	get_node("%NOGO").visible = gonogo and !gameover and skips > 0
	get_node("%RESTART").visible = gameover

func go():
	var player = driver.cur_state.get_player()
	for skill in skill_tree.unlocks:
		if skill.kind == Skill.Kind.Ability:
			player.append_ability(skill.ability)
		elif skill.kind == Skill.Kind.Bonus:
			player.append_bonus(skill.bonus)
	while driver.tick() and driver.history.size() < turn_limit:
		pass
	get_node("%history_view").view(driver.history, driver.map)
	gonogo = false
	update_button_visibility()

func no_go():
	skips -= 1
	make_encounter()

func done():
	# apply encounter consequences
	player_hp = driver.history.final().get_player().cur_hp
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
	
	driver = EncounterDriver.new()
	driver.initialize(state, map, encounter_seed)
	get_node("%state_view").init_view(DataUtil.deep_dup(state), map)
	gonogo = true
	update_button_visibility()


func create_enemy() -> CombatEntity:
	var nme = CombatEntity.new()
	var a = Actor.new()
	var reference_nme_idx = randi() % (Actor.Type.size() - 1) + 1
	nme.initialize_with_block(Actor.get_stat_block(reference_nme_idx), Constants.ENEMY_FACTION, Actor.get_name(reference_nme_idx))	
	nme.actor_type = Actor.get_type(reference_nme_idx)
	nme.elements = a.get_elements(reference_nme_idx)
	return nme

func toggle_skill_tree():
	$SkillTreePanel.visible = !$SkillTreePanel.visible
