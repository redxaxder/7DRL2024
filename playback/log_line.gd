extends Control

export var highlighted: bool = false setget set_highlighted
export var payload: int = 0
# warning-ignore:unused_signal
signal pressed

func _ready():
# warning-ignore:return_value_discarded
	$button.connect("pressed", self, "emit_signal", ["pressed"])
func set_highlighted(x):
	highlighted = x
	_update()

export var label: String = "" setget set_label
func set_label(x):
	$Label.text = x
	_update()

func _update():
	if !$button: return
	if highlighted:
		$button.add_stylebox_override("normal", preload("res://playback/style/log_line_highlighted.tres"))
	else:
		$button.add_stylebox_override("normal", preload("res://playback/style/log_line_normal.tres"))

