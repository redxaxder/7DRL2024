extends Control

var icon_index: int = 1234
var color: Color = Color(1,1,1)

func set_input(input:int):
	seed(input)
	icon_index = randi()
	var s = randf() / 2 + 0.5
	var v = randf() / 2 + 0.5
	var h = randf()
	color = Color.from_hsv(h,s,v)
	update()
#var elapsed = 0
#var limit = 1
#func _process(delta):
#	elapsed += delta
#	if elapsed > limit:
#		elapsed -= limit
#		set_input(randi())

func _draw():
	var shift = get_rect().size / 8
	for i in 32:
		var x = i % 4
		var y = i / 4
		var x2 = 7 - x
		if icon_index & (1 << i) > 0:
			var rect = Rect2(shift * Vector2(x,y), shift)
			draw_rect(rect, color)
			var rect2 = Rect2(shift * Vector2(x2,y), shift)
			draw_rect(rect2, color)
