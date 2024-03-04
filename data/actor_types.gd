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

const SPRITES = [ \
	preload("res://graphics/player.tscn"),
	preload("res://graphics/wolf.tscn"),
	preload("res://graphics/squid.tscn"),
	preload("res://graphics/blorp.tscn"),
	preload("res://graphics/snake.tscn"),
	preload("res://graphics/crab.tscn"),
	preload("res://graphics/imp/imp.png"),
	preload("res://graphics/shrine/shrine.png"),
	preload("res://graphics/goblin/goblin.png"),
	preload("res://graphics/gazer/gazer.tscn"),
  ]

# [brawn, brains, guts, eyesight, footwork, hustle]
const STAT_BLOCKS = [ \
	[10, 10, 10, 10, 10, 10], #default player stats, will probably be determined by skill tree stuff
	[15, 12, 8, 5, 12, 10],
	[5, 15, 10, 10, 3, 3],
	[5, 2, 12, 2, 2, 8],
	[2, 8, 16, 8, 20, 15], # ironically snakes have incredible footwork
	[12, 2, 15, 5, 15, 1],
	[3, 3, 3, 3, 3, 3], #TBD
	[3, 3, 3, 3, 3, 3], #TBD
	[3, 3, 3, 3, 3, 3], #TBD
	[3, 3, 3, 3, 3, 3], #TBD
]

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

# make_elements( [list of atk elements], {dict of modifiers}
var NO_ELEMENTS = make_elements([], {})
var ELEMENTS = { \
	Type.Wolf: 	make_elements([Elements.Kind.Physical], {Elements.Kind.Fire: 1.5}),
	Type.Squid:	make_elements([Elements.Kind.Physical], {}),
	Type.Blorp:	make_elements([Elements.Kind.Poison], {Elements.Kind.Ice: 1.5, Elements.Kind.Poison: 0.1}),
	Type.Snake:	make_elements([Elements.Kind.Poison, Elements.Kind.Physical], {Elements.Kind.Physical: 1.2}),
	Type.Crab:	make_elements([Elements.Kind.Physical], {Elements.Kind.Fire: 1.2}),
}


static func make_elements(atk_mods: Array, def_mods: Dictionary) -> Elements:
	var e = Elements.new()
	var am: Dictionary = {}
	for a in atk_mods:
		am[a] = true
	e.attack_modifiers = am
	e.defense_modifiers = def_mods
	return e

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
	

static func get_stat_block(t: int) -> StatBlock:
	var sb = StatBlock.new()
	sb.initialize_array(STAT_BLOCKS[t])
	return sb

static func get_name(t: int) -> String:
	return NAMES[t]

func get_elements(t: int) -> Elements:
	return ELEMENTS.get(t, NO_ELEMENTS)
