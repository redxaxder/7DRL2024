extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	print('in ready')
	pass

func _draw():
	print('in draw')
	var purple = Color("#B784B7")
	draw_circle(Vector2(200, 200), 100, purple)
	var peach = Color("#EEA5A6")
	draw_circle(Vector2(500, 200), 100, peach)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
