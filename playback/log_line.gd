extends Button

export var highlighted: bool = false setget set_highlighted

func set_highlighted(x):
	highlighted = x
	_update()

export var label: String = "" setget set_label
func set_label(x):
	$Label.text = x
	_update()

func _ready():
	_update()

func _update():
	if highlighted:
		add_stylebox_override("normal", preload("res://playback/style/log_line_highlighted.tres"))
	else:
		add_stylebox_override("normal", preload("res://playback/style/log_line_normal.tres"))
	
