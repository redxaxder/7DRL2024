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
			var is_passable = true
			if(x == 0 || x == Constants.MAP_BOUNDARIES.size.x-1
			|| y == 0 || y == Constants.MAP_BOUNDARIES.size.y-1
			|| randf() < .2):
				is_passable = false
			tiles[x].append(Tile.new(x,y,is_passable))
			
func createSprites(display: Control):
	for x in Constants.MAP_BOUNDARIES.size.x:
		for y in Constants.MAP_BOUNDARIES.size.y:
			var tile = tiles[x][y]
			var sprite = tile.sprite
			display.add_child(sprite)
			sprite.position = Vector2(100 * x, 100 *y)
			sprite.centered = false

func updateSprites(scaled_size, scale_factor):
	for x in Constants.MAP_BOUNDARIES.size.x:
		for y in Constants.MAP_BOUNDARIES.size.y:
			var tile = tiles[x][y]
			var sprite = tile.sprite
			sprite.position = Vector2(x * scaled_size, y * scaled_size)
			sprite.scale = Vector2(scale_factor, scale_factor)
			# TODO: 
		
func can_move(loc: Vector2) -> bool:
	return in_bounds(loc)  && is_passable(loc)
			
func in_bounds(loc: Vector2) -> bool:
	return Constants.MAP_BOUNDARIES.has_point(loc)
			
func is_passable(loc: Vector2) -> bool:
	var t = tiles[loc.x][loc.y]
	return t.passable
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
