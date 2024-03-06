class_name RandomUtil


static func color_hash(what) -> Color:
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(what)
	var s = rng.randf() / 2 + 0.5
	var v = rng.randf() / 2 + 0.5
	var h = rng.randf()
	return Color.from_hsv(h,s,v)
