class_name Actor
enum Type{ 
	Player,
	Wolf,
	Squid,
	Blorp,
	Snake,
	Crab,
	Imp,
	Shrine,
	Goblin,
	Gazer,
	BigShrine,
	Dragon,
	Hermit,
	}

const NAMES = [ \
	"You",
	"Wolf",
	"Squid",
	"Blorp",
	"Snake",
	"Crab",
	"Imp",
	"Shrine",
	"Goblin",
	"Gazer",
	"Shrine",
	"Dragon",
	"Hermit",
]

const SPRITES = [ \
	preload("res://graphics/player.tscn"),
	preload("res://graphics/wolf.tscn"),
	preload("res://graphics/squid.tscn"),
	preload("res://graphics/blorp.tscn"),
	preload("res://graphics/snake.tscn"),
	preload("res://graphics/crab.tscn"),
	preload("res://graphics/imp/imp.png"),
	preload("res://graphics/shrine/shrine0.png"),
	preload("res://graphics/goblin/goblin.png"),
	preload("res://graphics/gazer/gazer.tscn"),
	preload("res://graphics/shrine/shrine.png"),
	preload("res://graphics/dragon/dragon.png"),
	preload("res://graphics/hermit.png"),
  ]

const STATS = {
	Type.Player: {
		"base": [10, 10, 10, 10, 10, 10],
#		"base": [100, 100, 100, 100, 100, 100],
		Stat.Kind.Health: 30,
		 }, 
	Type.Gazer: {
		"base": [20,20,20,20,20,20],
		"attack": Elements.Kind.Ice,
		Stat.Kind.Speed: 200
		},
	Type.Imp: {
		"base": [6, 21, 9, 22, 4, 17],
		"attack": Elements.Kind.Fire,
		Stat.Kind.FireResist: 200,
		},
	Type.Wolf: {
		"base": [15, 12, 8, 5, 12, 10],
		Stat.Kind.FireResist: -50,
		},
	Type.Squid: {
		"base": [5, 15, 10, 10, 3, 3],
		},
	Type.Blorp: {
		"base": [5, 2, 12, 2, 2, 8],
		"attack": Elements.Kind.Poison,
		Stat.Kind.PoisonResist: 150,
		Stat.Kind.IceResist: -50,
		},
	Type.Snake: {
		"base": [2, 8, 16, 8, 20, 15], # ironically snakes have incredible footwork
		"attack": Elements.Kind.Poison,
		Stat.Kind.PhysicalResist: -80,
		Stat.Kind.Crit: 200,
		Stat.Kind.Damage: -5,
		},
	Type.Crab: {
		"base": [12, 2, 15, 5, 15, 1],
		"attack": Elements.Kind.Ice,
		Stat.Kind.PhysicalResist: 150,
		Stat.Kind.Speed: -10,
		},
	Type.Shrine: {
		"base": [1, 1, 1, 1, 1, 1],
		Stat.Kind.Health: 48, # 50 total
	},
	Type.BigShrine: {
		"base": [1, 1, 1, 1, 1, 1],
		Stat.Kind.Health: 98, # 100 total
	},
	Type.Goblin: {
		"base": [3,3,3,3,3,3],
		"attack": Elements.Kind.Fire,
		Stat.Kind.Evasion: 50,
	},
	Type.Dragon: {
		"base": [50,50,50,50,50,50],
		"attack": Elements.Kind.Fire,
		Stat.Kind.FireResist: 150,
		Stat.Kind.IceResist: 150,
	},
	Type.Hermit: {
		"base": [7,7,7,7, 7,7],
		"attack": Elements.Kind.Ice,
		Stat.Kind.PhysicalResist: 200,
	},
}

static func default_stats() -> Array:
#	push_warning("using stub stats. should probably put in real ones")
	return [3,3,3,3,3,3]

static func get_stat_block(t: int) -> StatBlock:
	var sb = StatBlock.new()
	var proto = STATS.get(t, null)
	var base_stats = null
	if proto != null:
		base_stats = proto.get("base")
	if base_stats == null:
		base_stats = default_stats()
	sb.initialize_array(base_stats)
	if proto: for key in proto.keys():
		if typeof(key) == TYPE_INT:
			var bonus = bonus(key, proto.get(key))
			sb.apply_bonus(bonus)
	return sb

static func bonus(stat: int, power: int) -> Bonus:
	var b = Bonus.new()
	b.stat =stat
	b.power = power
	return b

static func make_sprite(t) -> Sprite:
	var s = SPRITES[t]
	var sprite
	if s is PackedScene:
		sprite = s.instance()
	else:
		sprite = Sprite.new()
		sprite.texture = s
	sprite.centered = false
	return sprite

static func get_name(t: int) -> String:
	return NAMES[t]

static func get_element(t: int) -> int:
	var e = Elements.Kind.Physical
	var proto = STATS.get(t)
	if proto != null:
		e = proto.get("attack", e)
	return e

static func create_unit(unit_type: int, faction: int) -> CombatEntity:
	var unit = CombatEntity.new()
	unit.initialize_with_block(get_stat_block(unit_type), faction, get_name(unit_type))	
	unit.actor_type = unit_type
	unit.element = get_element(unit_type)
	return unit

const SHRINE_TYPES = [
	Stat.Kind.Accuracy,
	Stat.Kind.Damage,
	Stat.Kind.Crit,
	Stat.Kind.Evasion,
	Stat.Kind.Speed,
	Stat.Kind.Health,
]

static func create_shrine(stat: int) -> CombatEntity:
	var shrine = create_unit(Type.Shrine, Constants.ENEMY_FACTION)
	var shrine_spell = SkillTree.build_ability({
		"label": Stat.NAME[stat] + " Buff",
		"ability_range": 0,
		"trigger": SkillsCore.Trigger.Automatic,
		"filter": Activation.Filter.Start,
		"effect_type": SkillsCore.EffectType.StatBuff,
		"mod_stat": stat,
		"radius": 100,
		"power": 10,
		"targets": SkillsCore.Target.Allies,
		"cooldown_time": 100000,
	})
	shrine.name = Stat.NAME[stat] + " Shrine"
	shrine.append_ability(shrine_spell)
	shrine.inert = true
	return shrine

static func create_big_shrine(stat: int) -> CombatEntity:
	var shrine = create_unit(Type.BigShrine, Constants.ENEMY_FACTION)
	var big_shrine_spell = SkillTree.build_ability({
		"label": Stat.NAME[stat] + " Sacrifice",
		"ability_range": 0,
		"trigger": SkillsCore.Trigger.Automatic,
		"filter": Activation.Filter.Death,
		"effect_type": SkillsCore.EffectType.StatBuff,
		"mod_stat": stat,
		"radius": 100,
		"power": 10,
		"targets": SkillsCore.Target.Allies,
		"cooldown_time": 1,
	})
	shrine.name = "Greater " + Stat.NAME[stat] + " Shrine"
	shrine.append_ability(big_shrine_spell)
	shrine.inert = true
	return shrine

