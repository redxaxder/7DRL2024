class_name Actor
enum Type{ 
	Player, 
	Wolf,
	}

const SPRITES = [ \
	preload("res://graphics/player.tscn"),
	preload("res://graphics/wolf.tscn")
  ]

static func get_sprite(t) -> PackedScene:
	return SPRITES[t]
