extends Resource

class_name Map

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var tiles: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	print('in map')
	pass # Replace with function body.

func generate() -> bool:
	for i in 1000:
		generate_tiles()
		var num_passables = count_passables()
		# ensures there is enough space and its all connected space
		if num_passables > 10 && is_map_connected(num_passables):
			return true
	assert(false, "map generation timed out")
	return false
	
# returns the number of passable tiles
func generate_tiles():
	var r = randf()
	var fill_percent = 0.1;
	if r<.333:
		fill_percent = 0.3
	elif r<.66:
		fill_percent = 0.5
	
	
	tiles = [];
	for x in Constants.MAP_BOUNDARIES.size.x:
		tiles.append([])
		for y in Constants.MAP_BOUNDARIES.size.y:
			var is_passable = true
			if(x == 0 || x == Constants.MAP_BOUNDARIES.size.x-1
			|| y == 0 || y == Constants.MAP_BOUNDARIES.size.y-1
			|| randf() < fill_percent):
				is_passable = false
			tiles[x].append(Tile.new(x,y,is_passable))
	
func count_passables() -> int:
	var num_passables = 0
	for x in Constants.MAP_BOUNDARIES.size.x:
		for y in Constants.MAP_BOUNDARIES.size.y:
			if get_tile(x,y).passable:
				num_passables = num_passables + 1
	return num_passables

func list_passable() -> Array:
	var passable = []
	for x in Constants.MAP_BOUNDARIES.size.x:
		for y in Constants.MAP_BOUNDARIES.size.y:
			var t = get_tile(x,y)
			if t.passable:
				passable.append(t)
	return passable

func is_map_connected(num_passbles: int) -> bool:
	var island_size = get_connected_island(random_passable_tile(null)).size()
	print("island_size: {0} passables: {1}".format([island_size, num_passbles]))
	return island_size == num_passbles
	
func get_connected_island(starting_tile: Tile):
	var current = starting_tile
	var island = [current]
	var frontier = [current]
	while frontier.size() > 0:
		var tile = frontier.pop_back()
		var neighbors = get_all_neighbors(tile)
		for n in neighbors:
			if n.passable && island.find(n) == -1:
				island.append(n)
				frontier.append(n)
	return island
			
func get_all_neighbors(tile: Tile):
	return [
		get_neighbor(tile, 1,0),
		get_neighbor(tile, 1,1),
		get_neighbor(tile, 0,1),
		get_neighbor(tile, -1,1),
		get_neighbor(tile, -1,0),
		get_neighbor(tile, -1,-1),
		get_neighbor(tile, 0,-1),
		get_neighbor(tile, 1,-1)
	]
		
func get_neighbor(tile: Tile, dx: int, dy: int):
	return get_tile(tile.x + dx, tile.y + dy)
			
func createSprites(display: Control):
	for x in Constants.MAP_BOUNDARIES.size.x:
		for y in Constants.MAP_BOUNDARIES.size.y:
			var tile = tiles[x][y]
			var spr = tile.sprite
			display.add_child(spr)
			spr.position = Vector2(100 * x, 100 *y)
			spr.centered = false

func updateSprites(scaled_size, scale_factor):
	for x in Constants.MAP_BOUNDARIES.size.x:
		for y in Constants.MAP_BOUNDARIES.size.y:
			var tile = tiles[x][y]
			var spr = tile.sprite
			spr.position = Vector2(x * scaled_size, y * scaled_size)
			spr.scale = Vector2(scale_factor, scale_factor)
			# TODO: 
		
func can_move(loc: Vector2) -> bool:
	return in_bounds(loc)  && is_passable(loc)
			
func in_bounds(loc: Vector2) -> bool:
	return Constants.MAP_BOUNDARIES.has_point(loc)
			
func is_passable(loc: Vector2) -> bool:
	var t = tiles[loc.x][loc.y]
	return t.passable
	
func get_tile(x:int, y:int) -> Tile:
	return tiles[x][y]
	
func random_passable_tile(state: EncounterState) -> Tile:
	for i in 10000:
		var tile = get_random_tile()
		# check passable and if the tile is not occupied
		if tile.passable && (!state || !state.lookup_actor(tile.loc)):
			return tile
	assert(false, "random_passable_tile timed out")
	return null
		
func get_random_tile() -> Tile:
# warning-ignore:narrowing_conversion
# warning-ignore:narrowing_conversion
	return get_tile(
		rand_range(1,Constants.MAP_BOUNDARIES.size.x-2),
		rand_range(1,Constants.MAP_BOUNDARIES.size.y-2)
	)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
