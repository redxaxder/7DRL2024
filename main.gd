extends Node2D

var player_stats: StatBlock
var player_hp: int

var driver: EncounterDriver

const turn_limit = 500

func _ready():
	randomize()
	player_stats = StatBlock.new()
	var s = Actor.STAT_BLOCKS[Actor.Type.Player]
	player_stats.initialize(s[0],s[1],s[2],s[3],s[4],s[5])

# warning-ignore:return_value_discarded
	get_node("%GO").connect("pressed",self,"go")
# warning-ignore:return_value_discarded
	get_node("%NOGO").connect("pressed",self,"no_go")
# warning-ignore:return_value_discarded
	get_node("%DONE").connect("pressed",self,"done")
# warning-ignore:return_value_discarded
	get_node("%history_view").connect("updated", self, "history_scroll")

	make_encounter(1234)


func history_scroll(s: EncounterState, what: EncounterEvent):
	get_node("%state_view").update_view(s, what)

func go():
	get_node("%history_view").view(driver.history, driver.map)
	get_node("%DONE").visible = true
	get_node("%GO").visible = false
	get_node("%NOGO").visible = false

func no_go():
	make_encounter()

func done():
	# apply encounter consequences (none right now)
	make_encounter()
	get_node("%DONE").visible = false
	get_node("%GO").visible = true
	get_node("%NOGO").visible = true

func make_encounter(use_seed: int = 0):
	var encounter_seed = use_seed
	if encounter_seed == 0:
		encounter_seed = randi()
	prints("encounter seed", encounter_seed)

	seed(encounter_seed)
	get_node("%history_view").clear()
	var map = Map.new()

	var state = EncounterState.new()
	var player = CombatEntity.new()
	player.initialize_with_block(player_stats, Constants.PLAYER_FACTION)
	player.actor_type = Actor.Type.Player
	var abil = SkillTree.create_ability(Ability.TargetKind.Self, Ability.TriggerEffectKind.Damage, Ability.AbilityEffectKind.Damage, 1, Ability.TargetKind.Enemies, "Lashed out!")
	player.append_ability(abil)
	state.add_actor(player, Vector2(1, 1))
	

	for _i in range(3):
		var nme = create_enemy()
		var nme_loc = Vector2(randi() % 5 + 5, randi() % 10)
		for _retry in 5: 
			if state.lookup_actor(nme_loc) == null: break
			nme_loc = Vector2(randi() % 5 + 5, randi() % 10)
		state.add_actor(nme, nme_loc)
	
	driver = EncounterDriver.new()
	driver.initialize(state, map, encounter_seed)
	while driver.tick() and driver.history.size() < turn_limit:
		pass
	get_node("%state_view").init_view(driver.history.initial(), map)


func create_enemy() -> CombatEntity:
	var nme = CombatEntity.new()
	var reference_nme_idx = randi() % (Actor.Type.size() - 1) + 1
	nme.initialize_with_block(Actor.get_stat_block(reference_nme_idx), Constants.ENEMY_FACTION)	
	nme.actor_type = Actor.get_type(reference_nme_idx)
	return nme


