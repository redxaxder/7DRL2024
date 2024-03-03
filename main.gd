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

	make_encounter()

# warning-ignore:return_value_discarded
	get_node("%GO").connect("pressed",self,"go")
# warning-ignore:return_value_discarded
	get_node("%NOGO").connect("pressed",self,"no_go")


func go():
	while driver.tick() and driver.history.size() < turn_limit:
		pass
	var history_viewer = get_node("%history_view")
	history_viewer.view(driver.history, driver.map)
	make_encounter()

func no_go():
	make_encounter()

func make_encounter():
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
	driver.initialize(state, map)


func create_enemy() -> CombatEntity:
	var nme = CombatEntity.new()
	var reference_nme_idx = randi() % (Actor.Type.size() - 1) + 1
	nme.initialize_with_block(Actor.get_stat_block(reference_nme_idx), Constants.ENEMY_FACTION)	
	nme.actor_type = Actor.get_type(reference_nme_idx)
	return nme


