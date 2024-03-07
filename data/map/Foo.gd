extends Resource

class_name Foo

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var MAP_SIZE = Vector2(16,16)
var tiles: Array;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func generate():
	tiles = [];
	for x in MAP_SIZE.x:
		tiles[x] = [];
		for y in MAP_SIZE.y:
			tiles[x][y] = Tile.new(x,y,true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
