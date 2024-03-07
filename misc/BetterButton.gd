tool
extends Panel

# warning-ignore:unused_signal
signal pressed

export var image: Texture setget set_image
func set_image(x):
	image = x
	_refresh()

export var text: String setget set_text
func set_text(x):
	text = x
	_refresh()

export(int, "Left", "Center", "Right", "Fill") var align setget set_align
func set_align(x):
	align = x
	_refresh()

export(int, "Top", "Center", "Bottom", "Fill") var valign setget set_valign
func set_valign(x):
	valign = x
	_refresh()

export var font_size:int = 16 setget set_font_size
func set_font_size(x):
	font_size = x
	_refresh()

export var hover_mod: Color = Color(1,1,1,1)
export var use_hover_mod: bool = false

var base_color: Color
func _ready():
# warning-ignore:return_value_discarded
	$Button.connect("pressed",self,"emit_signal", ["pressed"])
	base_color = modulate

func _refresh():
	var stylebox = StyleBoxTexture.new()
	stylebox.texture = image
	add_stylebox_override("panel", stylebox)
	var label = get_node_or_null("Label") 
	if label != null:
		label.text = text
		label.align = align
		label.valign = valign
		var font = DynamicFont.new()
		font.font_data = preload("res://fonts/CommitMono-400-Regular.otf")
		font.size = font_size
		label.add_font_override("font", font)

func mouse_entered():
	modulate = hover_mod
func mouse_exited():
	modulate = base_color

func _notification(what):
	if what == NOTIFICATION_MOUSE_ENTER: mouse_entered()
	elif what == NOTIFICATION_MOUSE_EXIT: mouse_exited()
	elif what == NOTIFICATION_VISIBILITY_CHANGED: mouse_exited()
