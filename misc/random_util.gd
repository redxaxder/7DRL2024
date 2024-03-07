class_name RandomUtil


static func color_hash(what) -> Color:
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(what)
	var h = rng.randf()
	var s = rng.randf()*.5 + 0.5
	var v = rng.randf()*.3 + 0.6
	return Color.from_hsv(h,s,v)
