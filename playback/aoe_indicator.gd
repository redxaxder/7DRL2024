extends Control


export var texture: Texture
export var location: Vector2
export var color: Color
export var radius: int
export var scale_factor: float

func _draw():
	var scaled_size = scale_factor * Constants.TILE_ENVELOPE
	var min_x = int(max(location.x-radius, Constants.MAP_BOUNDARIES.position.x))
	var max_x = int(min(location.x+radius, Constants.MAP_BOUNDARIES.size.x + Constants.MAP_BOUNDARIES.position.x-1))
	var min_y = int(max(location.y-radius, Constants.MAP_BOUNDARIES.position.y))
	var max_y = int(min(location.y+radius, Constants.MAP_BOUNDARIES.size.y + Constants.MAP_BOUNDARIES.position.y-1))
	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			var target_location = Vector2(x,y)
			var position = target_location * scaled_size - Vector2(scale_factor, scale_factor)
			var size = Vector2(1,1) * (scaled_size + scale_factor)
			var target_rect = Rect2(position, size)
			draw_texture_rect(texture, target_rect, false, color)
