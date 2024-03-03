class_name Actor
enum Type{ 
	Player, 
	Wolf,
	Squid,
	Blorp,
	}

const SPRITES = [ \
	preload("res://graphics/player.tscn"),
	preload("res://graphics/wolf.tscn"),
	preload("res://graphics/squid.tscn"),
	preload("res://graphics/blorp.tscn"),
  ]

# [brawn, brains, guts, eyesight, footwork, hustle]
const STAT_BLOCKS = [ \
	[10, 10, 10, 10, 10, 10], #default player stats, will probably be determined by skill tree stuff
	[15, 12, 8, 5, 12, 10],
	[5, 15, 10, 10, 3, 3],
	[5, 2, 12, 2, 2, 8],
]

const NAMES = [ \
	"Player",
	"Wolf",
	"Squid",
	"Blorp",
]

static func get_sprite(t) -> PackedScene:
	return SPRITES[t]

static func get_stat_block(t) -> StatBlock:
	var sb = StatBlock.new()
	sb.initialize(STAT_BLOCKS[t][0], STAT_BLOCKS[t][1], STAT_BLOCKS[t][2], STAT_BLOCKS[t][3], STAT_BLOCKS[t][4], STAT_BLOCKS[t][5])
	return sb

static func get_type(t):
	match t:
		0: return Type.Player
		1: return Type.Wolf
		2: return Type.Squid
		3: return Type.Blorp

static func get_name(t):
	return NAMES[t]
