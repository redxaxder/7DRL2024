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
  ]

const STATS = {
	Type.Player: {
		"base": [10, 10, 10, 10, 10, 10],
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
		Stat.Kind.PoisonResist: 90,
		Stat.Kind.IceResist: -50,
		},
	Type.Snake: {
		"base": [2, 8, 16, 8, 20, 15], # ironically snakes have incredible footwork
		"attack": Elements.Kind.Poison,
		Stat.Kind.PhysicalResist: -20,
		},
	Type.Crab: {
		"base": [12, 2, 15, 5, 15, 1],
		Stat.Kind.PhysicalResist: 50,
		Stat.Kind.Speed: -10,
		},
	Type.Shrine: {
		"base": [1, 1, 1, 1, 1, 1],
		Stat.Kind.Health: 48, # 50 total
		Stat.Kind.Speed: 8, # 10 total
	}
}

# spawn table TODO, imp goblin gazer
 #move stuff medium once we have scaling and harder stuff
const SPAWN_EASY = [Type.Blorp, Type.Snake]
const SPAWN_MEDIUM = [Type.Crab, Type.Squid]
const SPAWN_HARD = [Type.Wolf]

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

static func create_shrine(stat: int) -> CombatEntity:
	var shrine = create_unit(Type.Shrine, Constants.ENEMY_FACTION)
	var shrine_spell = SkillTree.build_ability({
		"label": Stat.NAME[stat] + " Buff",
		"ability_range": 20,
		"trigger": SkillsCore.Trigger.Action,
		"effect_type": SkillsCore.EffectType.StatBuff,
		"mod_stat": stat,
		"power": 1,
		"targets": SkillsCore.Target.Allies,
		"cooldown_time": 1,
	})
	shrine.name = Stat.NAME[stat] + " Shrine"
	shrine.append_ability(shrine_spell)
	return shrine

