tool
extends Control

export(float, 0,1) var fill_percent: float = 1.0 setget set_fill_percent
func set_fill_percent(x):
	fill_percent = x
	update()

export var breakpoints: int = 6

const FOREGROUND: Color = Color(0,1,0)
const BACKGROUND: Color = Color(0.4,0.4,0.4)

func _draw():
	var x = round(fill_percent * breakpoints)
	if fill_percent > 0:
		x = max(x,1)
	x = x / float(breakpoints)
	var filled: Rect2 = Rect2(Vector2.ZERO, Vector2(x,1) * rect_size)
	draw_rect(filled, FOREGROUND)
	
