extends Resource

class_name Tile

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var x: int
var y: int
var loc: Vector2
var xy: String
var passable: bool
var sprite

const wall_sprite = preload("res://graphics/wall.tscn")
const floor_sprite = preload("res://graphics/floor.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _init(p_x, p_y, p_passable):
	x = p_x;
	y = p_y;
	passable = p_passable;
	loc = Vector2(x,y)
	xy = "{0}-{1}".format([x,y])
	
#	if(passable):
#		sprite = floor_sprite.instance()
#		sprite.modulate = Color("#523c42")
#	else:
#		sprite = wall_sprite.instance()
#		sprite.modulate = Color("#67968a")

func get_sprite() -> PackedScene:
	if passable: return  floor_sprite
	else: return wall_sprite
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
