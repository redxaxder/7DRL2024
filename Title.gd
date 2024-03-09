extends Panel

const LogLine = preload("res://playback/log_line.tscn")

signal select
func add_unlocked_line(i: int):
	var unlocks = get_node("%unlocks")
	var unlockline = LogLine.instance()
	unlocks.add_child(unlockline)
	var treename = Meta.tree_name(i)
	unlockline.set_label(str(i," ", treename))
	unlockline.connect("pressed", self, "log_click", [i])
	unlockline.payload = i

func log_click(id: int):
	emit_signal("select", id)
	for logline in get_node("%unlocks").get_children():
		logline.highlighted = id == logline.payload

func pick_something():
	var unlocks = get_node("%unlocks")
	if unlocks.get_child_count() > 0:
		log_click(unlocks.get_child(0).payload)
	else:
		log_click(randi() % 366)
