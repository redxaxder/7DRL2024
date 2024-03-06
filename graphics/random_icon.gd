extends Button

var icon_index: int = 1234
var color: Color = Color(1,1,1)
var scale: int = 8
var full_size: int = 10

func set_input(input):
	icon_index = hash(input)
	color = RandomUtil.color_hash(input)
	color = Color.white
	update_texture()

func update_texture():
	seed(icon_index)
	var image = Image.new()
	var dim = Vector2(full_size, full_size)*scale
	image.create(dim.x,dim.y,false,Image.FORMAT_RGBA8)
	image.fill(Color(0,0,0,0))
	image.lock()

	for x in full_size: for y in full_size	:
		var off = (randf()>.4 ||
			x == 0 || x == full_size -1 ||
			y == 0 || y == full_size - 1)
		for xx in scale: for yy in scale:
			var xxx = scale * x + xx
			var yyy = scale * y + yy
			var xxxx = dim.x - xxx - 1
			if !off && ((yy + 0.0) / scale) < randf():
				image.set_pixel(xxx,yyy, color)
				image.set_pixel(xxxx,yyy, color)
#	for x in dim.x: for y in dim.y:
#		var i = 8*(int(x)/scale) + int(y)/scale
#		var x2 = dim.x - x - 1
#		if icon_index & (1 << i) > 0:
#			image.set_pixel(x,y, color)
#			image.set_pixel(x2,y, color)

	var t = ImageTexture.new()
	t.create_from_image(image, 0)
	icon = t
