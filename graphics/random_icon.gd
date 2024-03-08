extends Button

var icon_index: int = 1234
var color: Color = Color(1,1,1)
var scale: int = 8
var full_size: int = 10
var resolution: float = full_size * scale
var rng = RandomNumberGenerator.new()
var skill

var center = Vector2(4.5,4.5)

func set_input(input_skill):
	skill = input_skill
	icon_index = hash(input_skill.name)
	rng.seed = icon_index
	color = Color.white
	update_texture()

func update_texture():
	rng.seed = icon_index
	var image = Image.new()
	var dim = Vector2(full_size, full_size)*scale
	image.create(dim.x,dim.y,false,Image.FORMAT_RGBA8)
	image.fill(Color(0,0,0,0))
	image.lock()
	
	var flip_x = should_flip_x()
	var flip_y = should_flip_y()
	
	for x in full_size: for y in full_size	:
		var d = dist(Vector2(float(x), float(y)), center)
		var outline = (x == 0 || x == full_size -1 ||
			y == 0 || y == full_size - 1)
		var off = get_big_off(x,y, d) || outline
		if flip_x && x > full_size/2.0:
			continue
		if flip_y && y > full_size/2.0:
			continue
		
		for xx in scale: for yy in scale:
			var xxx = scale * x + xx
			var yyy = scale * y + yy
			var yyyy = dim.y - yyy - 1
			var xxxx = dim.x - xxx - 1
			if !off && get_on(x, y, xx, yy, d):
				image.set_pixel(xxx,yyy, color)
				
				if flip_x:
					image.set_pixel(xxxx,yyy, color)
				if flip_y:
					image.set_pixel(xxx,yyyy, color)
				if flip_x && flip_y:
					image.set_pixel(xxxx,yyyy, color)
#	for x in dim.x: for y in dim.y:
#		var i = 8*(int(x)/scale) + int(y)/scale
#		var x2 = dim.x - x - 1
#		if icon_index & (1 << i) > 0:
#			image.set_pixel(x,y, color)
#			image.set_pixel(x2,y, color)

	var t = ImageTexture.new()
	t.create_from_image(image, 0)
	icon = t
	
func should_flip_x():
	if skill.bonus:
		return true;
	if skill.ability && skill.ability.effect:
		if skill.ability.effect.element == Elements.Kind.Physical:
			return true
		elif skill.ability.effect.element == Elements.Kind.Poison:
			return true
		elif skill.ability.effect.element == Elements.Kind.Fire:
			return true
		elif skill.ability.effect.element == Elements.Kind.Ice:
			return true
	
func should_flip_y():
	if skill.bonus:
		return true;
	if skill.ability && skill.ability.effect:
		if skill.ability.effect.element == Elements.Kind.Physical:
			return false
		elif skill.ability.effect.element == Elements.Kind.Poison:
			return false
		elif skill.ability.effect.element == Elements.Kind.Fire:
			return false
		elif skill.ability.effect.element == Elements.Kind.Ice:
			return true
	
func get_big_off(x,y, d):
	if skill.bonus:
		pass
	if skill.ability && skill.ability.effect:
		if skill.ability.effect.element == Elements.Kind.Physical:
			pass
		elif skill.ability.effect.element == Elements.Kind.Poison:
			return ((1 - (d - 1) / 6)*0.3 + 0.2) < rng.randf()
		elif skill.ability.effect.element == Elements.Kind.Fire:
			return pow((float(max(0,y+0.5 -x*0.5))/full_size), 1) < rng.randf()
			# 0 means => OFF
			# 1 means => ON
			
			# 0,0 => 0
			# 4,0 => 1
			# 0,8 => 1
			# 4,8 => 1
		elif skill.ability.effect.element == Elements.Kind.Ice:
			pass
	return (rng.randf()>.4)
	
func dist(a: Vector2, b: Vector2) -> float:
	return pow(pow(a.x - b.x,2.0) + pow(a.y-b.y,2.0), 0.5)

func get_on(x, y, xx, yy, d):
	var inner_d = dist(Vector2(float(xx),float(yy)), Vector2(3.5, 3.5))
	var full_d = dist(Vector2(float(x*scale + xx),float(y*scale + yy)), Vector2(3.5*scale, 3.5*scale))
	if skill.bonus:
		return (3 - d + cos(y*scale + yy))  < rng.randf()
	if skill.ability && skill.ability.effect:
		if skill.ability.effect.element == Elements.Kind.Physical:
			return ((yy + 0.0) / scale) < rng.randf()
		elif skill.ability.effect.element == Elements.Kind.Poison:
			return (inner_d - 4 + d*0.85) / 2 < rng.randf()
		elif skill.ability.effect.element == Elements.Kind.Fire:
			var a = (1-(y * scale + yy) / resolution) 
			var b = 0.5*(-xx + -x * scale + scale * full_size / 2.0) / resolution
			return (a + b) < rng.randf()
		elif skill.ability.effect.element == Elements.Kind.Ice:
			return (cos(full_d)*0.6+0.4 * (1.0-full_d/20.0))> rng.randf()

