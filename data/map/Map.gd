extends Resource

class_name Map

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var tiles: Array
var sprite: Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	print('in map')
	pass # Replace with function body.

func generate():
	tiles = [];
	for x in Constants.MAP_BOUNDARIES.size.x:
		tiles.append([])
		for y in Constants.MAP_BOUNDARIES.size.y:
			tiles[x].append(Tile.new(x,y,true))
			
func createSprites(display: Control):
	for x in Constants.MAP_BOUNDARIES.size.x:
		for y in Constants.MAP_BOUNDARIES.size.y:
			var tile = tiles[x][y]
			var sprite = tile.sprite
			display.add_child(sprite)
			sprite.position = Vector2(100 * x, 100 *y)
	
func updateSprites(scaled_size, scale_factor):
	for x in Constants.MAP_BOUNDARIES.size.x:
		for y in Constants.MAP_BOUNDARIES.size.y:
			var tile = tiles[x][y]
			var sprite = tile.sprite
			sprite.position = Vector2(x * scaled_size, y * scaled_size)
			sprite.scale = Vector2(scale_factor, scale_factor)
			# TODO: 
			
func is_passable(loc: Vector2):
	return tiles[loc.x][loc.y].passable
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
