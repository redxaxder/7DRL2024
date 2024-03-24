extends Panel

const LogLine = preload("res://playback/log_line.tscn")

signal select

func set_victory(is_victory: bool):
	if get_node_or_null("Title"): $Title.visible = !is_victory
	if get_node_or_null("victorytext"): $victorytext.visible = is_victory

func mark_won(i: int):
	for unlockline in get_node("%unlocks").get_children():
		if unlockline.payload == i:
			unlockline.modulate = Color(0.623529, 0.788235, 0.035294)
			
func clear_unlocks():
	var unlocks = get_node("%unlocks")
	for child in unlocks.get_children():
		child.queue_free()
		unlocks.remove_child(child)

func add_unlocked_line(i: int, did_win: bool):
	var unlocks = get_node("%unlocks")
	var unlockline = LogLine.instance()
	unlocks.add_child(unlockline)
	var treename = Meta.tree_name(i)
	unlockline.set_label(str(i," ", treename))
	unlockline.connect("pressed", self, "log_click", [i])
	unlockline.payload = i
	if did_win:
		unlockline.modulate = Color(0.623529, 0.788235, 0.035294)

func log_click(id: int):
	emit_signal("select", id)
	for logline in get_node("%unlocks").get_children():
		logline.highlighted = id == logline.payload

func pick_something():
	var unlocks = get_node("%unlocks")
	if unlocks.get_child_count() > 0:
		log_click(unlocks.get_child(0).payload)
	else:
		log_click(Meta.get_date_index())
