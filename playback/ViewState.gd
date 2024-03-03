extends Control

export var state: Resource
export var map: Resource

func _ready():
	var r = get_rect()
	print(r)

func init_view(s: EncounterState, m: Map):

	var terrain = get_node("%terrain")
	for child in terrain.get_children(): child.queue_free()
	map = m
	map.createSprites(terrain)

	var actors = get_node("%actors")
	for child in actors.get_children(): child.queue_free()
	state = s
	for i in state.actors.size():
		var actor = state.actors[i]
		var sprite = Actor.get_sprite(actor.actor_type).instance()
		actors.add_child(sprite)
		sprite.position = Vector2(100,100)
	update_view(s)

static func display_scale(display_size: Vector2, grid_size: Vector2) -> float:
	var tile_bounds = display_size / grid_size
	var scale_factor = floor(min(tile_bounds.x, tile_bounds.y)/ Constants.TILE_ENVELOPE)
	return scale_factor

func update_view(s: EncounterState):
	state = s
	var r = get_rect()
	print(r)
	var display_size: Vector2 = r.size
	var scale_factor = display_scale(display_size, Constants.MAP_BOUNDARIES.size)
	var scaled_size = scale_factor * Constants.TILE_ENVELOPE
#	assert(scale_factor > 0)

	var n = s.actors.size()
	var actors = get_node("%actors").get_children()
	for i in n:
		var actor = s.actors[i]
		actors[i].position = actor.location * scaled_size
		actors[i].scale = Vector2(scale_factor, scale_factor)
		actors[i].visible = actor.is_alive()
	
	map.updateSprites(scaled_size, scale_factor)

func _refresh():
	if !state: return
	pass

func get_tile_scale() -> int:
	var display_size: Vector2 = get_rect().size
	var tile_envelope = Constants.TILE_SIZE + Constants.TILE_MARGIN
	var tile_bounds = display_size / Constants.MAP_BOUNDARIES.size
	var scale_factor = floor(min(tile_bounds.x, tile_bounds.y)/ tile_envelope)
	return scale_factor
	var scaled_size = scale_factor * tile_envelope
