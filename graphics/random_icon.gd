extends Button

var icon_index: int = 1234
var color: Color = Color(1,1,1)
var scale: int = 8

func set_input(input):
	seed(hash(input))
	icon_index = randi()
	var s = randf() / 2 + 0.5
	var v = randf() / 2 + 0.5
	var h = randf()
	color = Color.from_hsv(h,s,v)
	update_texture()

func update_texture():
	var image = Image.new()
	var dim = Vector2(8,8)*scale
	image.create(dim.x,dim.y,false,Image.FORMAT_RGBA8)
	image.fill(Color(0,0,0,0))
	image.lock()
	for x in dim.x: for y in dim.y:
		var i = 8*(int(x)/scale) + int(y)/scale
		var x2 = dim.x - x - 1
		if icon_index & (1 << i) > 0:
			image.set_pixel(x,y, color)
			image.set_pixel(x2,y, color)
	var t = ImageTexture.new()
	t.create_from_image(image, 0)
	icon = t
