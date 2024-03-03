extends Resource

class_name Tile

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var x: int
var y: int
var passable: bool
var sprite

const wall_sprite = preload("res://graphics/wall.tscn")
const floor_sprite = preload("res://graphics/floor.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _init(x, y, passable):
	x = x;
	y = y;
	passable = passable;
	
	if(passable):
		sprite = floor_sprite.instance()
	else:
		sprite = wall_sprite.instance()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
