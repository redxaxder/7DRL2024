extends Control

export var state: Resource
export var map: Resource

const actor_base_color: Color = Color(1,1,1)
const subject_color: Color = Color(0.349911, 0.871094, 0.773372)
const target_actor_color: Color = Color(0.871094, 0.740798, 0.349911)
const target_location_color: Color = Color(0.439489, 0.349911, 0.871094)

func init_view(s: EncounterState, m: Map):
	var terrain = get_node("%terrain")
	for child in terrain.get_children():
		child.queue_free()
		terrain.remove_child(child)
	map = m
	map.createSprites(terrain)
	var actors = get_node("%actors")
	for child in actors.get_children():
		child.queue_free()
		actors.remove_child(child)

	state = s
	for i in state.actors.size():
		var actor = state.actors[i]
		var sprite = Actor.get_sprite(actor.actor_type).instance()
		actors.add_child(sprite)
		sprite.position = Vector2(100,100)
		sprite.centered = false
	update_view(s)

static func display_scale(display_size: Vector2, grid_size: Vector2) -> float:
	var tile_bounds = display_size / grid_size
	var scale_factor = floor(min(tile_bounds.x, tile_bounds.y)/ Constants.TILE_ENVELOPE)
	return scale_factor

func update_view(s: EncounterState, what: EncounterEvent = null):
	state = s
	get_node("%player_hp").text = "Hp: %d" % max(0,s.get_player().cur_hp)
	var display_size: Vector2 = get_rect().size
	var scale_factor = display_scale(display_size, Constants.MAP_BOUNDARIES.size)
	var scaled_size = scale_factor * Constants.TILE_ENVELOPE

	var n = s.actors.size()
	var actorsprites = get_node("%actors").get_children()
	assert(n == actorsprites.size())
	for i in n:
		var actor: CombatEntity = s.actors[i]
		actorsprites[i].position = actor.location * scaled_size
		actorsprites[i].scale = Vector2(scale_factor, scale_factor)
		actorsprites[i].visible = actor.is_alive()
		if what and actor.entity_index == what.actor_idx:
			actorsprites[i].modulate = subject_color
		elif what and actor.entity_index == what.target_idx:
			actorsprites[i].modulate = target_actor_color
		else:
			actorsprites[i].modulate = actor_base_color
	if what and what.target_location != null \
		and what.kind != EncounterEvent.EventKind.Move:
		$location_highlight.rect_position = what.target_location * scaled_size
		$location_highlight.visible = true
		$location_highlight.rect_size = scaled_size * Vector2(1,1)
	else:
		$location_highlight.visible = false
		
	map.updateSprites(scaled_size, scale_factor)

