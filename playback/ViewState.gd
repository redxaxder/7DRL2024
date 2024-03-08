extends Control

export var state: Resource
export var map: Resource

const actor_base_color: Color = Color(0.75, 0.75, 0.75)
const subject_color: Color = Color(1, 1, 1)
const target_actor_color: Color = Color(0.871094, 0.740798, 0.349911)
const target_location_color: Color = Color(0.439489, 0.349911, 0.871094)

signal actor_hovered(actor)


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
		var sprite = Actor.make_sprite(actor.actor_type)
		actors.add_child(sprite)
		var hotspot = Control.new()
		sprite.add_child(hotspot)
		hotspot.rect_size = Constants.TILE_SIZE * Vector2(1,1)
		hotspot.connect("mouse_entered", self, "actor_hover", [true, i])
		hotspot.connect("mouse_exited", self, "actor_hover", [false, i])
	update_view(s)

var hover_index = -1
func actor_hover(is_hover: bool, index: int):
	if is_hover:
		hover_index = index
	elif index == hover_index:
		hover_index = -1
	emit_hover()

func emit_hover():
	if hover_index >= 0 and hover_index < state.actors.size():
		emit_signal("actor_hovered", state.actors[hover_index])
	else:
		emit_signal("actor_hovered", null)

static func display_scale(display_size: Vector2, grid_size: Vector2) -> float:
	var tile_bounds = display_size / grid_size
	var scale_factor = floor(min(tile_bounds.x, tile_bounds.y)/ Constants.TILE_ENVELOPE)
	return scale_factor

func update_view(st: EncounterState, what: EncounterEvent = null):
	$reticle.visible = false
	$reticle2.visible = false
	state = st
	get_node("%player_hp").text = "Hp: {0} / {1}".format([
		max(0,st.get_player().cur_hp),
		st.get_player().stats.max_hp()
	])
	var display_size: Vector2 = get_rect().size
	var scale_factor = display_scale(display_size, Constants.MAP_BOUNDARIES.size)
	var scaled_size = scale_factor * Constants.TILE_ENVELOPE

	var n = st.actors.size()
	var actorsprites = get_node("%actors").get_children()
	assert(n <= actorsprites.size())
	for a in actorsprites:
		a.visible = false
	$hp_bar.visible = false
	$aoe_indicator.visible = false
	for i in n:
		var actor: CombatEntity = st.actors[i]
		actorsprites[i].position = actor.location * scaled_size
		actorsprites[i].scale = Vector2(scale_factor, scale_factor)
		actorsprites[i].visible = actor.is_alive()
		if what and actor.entity_index == what.actor_idx:
			actorsprites[i].modulate = subject_color
		else:
			actorsprites[i].modulate = actor_base_color
		if what and actor.entity_index == what.target_idx:
			$reticle.scale = Vector2(scale_factor, scale_factor)
			$reticle.position = actorsprites[i].position - $reticle.scale
			$reticle.visible = true
			if what.kind == EncounterEventKind.Kind.Damage:
				var bar_offset = scale_factor * Vector2(1,-1)
				$hp_bar.rect_position = actorsprites[i].position + bar_offset
				$hp_bar.rect_size = scale_factor * Vector2(Constants.TILE_SIZE - 2,1)
				$hp_bar.visible = true
				$hp_bar.fill_percent = max(0,float(actor.cur_hp)) / float(actor.stats.max_hp())
#			actorsprites[i].modulate = target_actor_color
	if what and what.target_location != null and !$reticle.visible \
		and what.kind != EncounterEventKind.Kind.Move:
		$reticle2.scale = Vector2(scale_factor, scale_factor)
		$reticle2.position = what.target_location * scaled_size - $reticle2.scale
		$reticle2.visible = true
		if !what.get("ability"):
			$reticle2.modulate = Color(0.5,0.5,0,5)
		else:
			var color = RandomUtil.color_hash(what.ability.name)
			$reticle2.modulate = color
			if what.displayed_radius > 0:
				$aoe_indicator.radius = what.displayed_radius
				$aoe_indicator.location = what.target_location
				$aoe_indicator.color = color
				$aoe_indicator.scale_factor = scale_factor
				$aoe_indicator.visible = true
	else:
		$location_highlight.visible = false
		
	map.updateSprites(get_node("%terrain"), scaled_size, scale_factor)
	emit_hover()
