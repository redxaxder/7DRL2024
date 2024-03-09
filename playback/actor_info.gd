extends Control

var actor: CombatEntity setget set_actor
func set_actor(x):
	actor = x
	_refresh()

func _refresh():
	if !actor:
		visible = false
		return
	visible = true
	get_node("%actorname").text = actor.name
	var methods = [
		"max_hp", 
		"damage", 
		"speed",
		"accuracy", 
		"evasion",
		"crit",
		"crit_chance",
		"crit_mult",
		"physical", "fire", "poison", "ice",
		"physical_resist", "fire_resist", "poison_resist", "ice_resist"
	]
	var dict = {}
	for k in methods: dict[k] = actor.stats.call(k)
	
	dict["cur_hp"] = max(0,actor.cur_hp)
	dict["crit_chance"] = int(actor.stats.crit_chance() * 100)
	dict["crit_mult"] = round(actor.stats.crit_mult() * 10) / 10
	
	var stats = get_node("%stats")
	if !stats: return
	for c in stats.get_children():
		c.queue_free()
		stats.remove_child(c)
	
	for key in methods:
		var field
		var value
		if key == "max_hp":
			field = "Hp:"
			value = "{cur_hp} / {max_hp}".format(dict)
		else:
			assert(field_display.has(key), str("missing ", key))
			field = str(field_display.get(key, "MISSING"),":")
#			assert(field != "NISSING:")
			value = str("{", key, "}").format(dict)
		var is_shown = dict[key] != 0 or key == "max_hp"
		if is_shown:
			var label1 = Label.new()
			stats.add_child(label1)
			label1.text = field
			var label2 = Label.new()
			stats.add_child(label2)
			label2.text = value
			label2.align = HALIGN_RIGHT

const field_display: Dictionary = {
	"speed": "Speed",
	"accuracy": "Accuracy",
	"evasion": "Evasion",
	"damage": "Attack",
	"crit": "Base Crit",
	"crit_chance": "Crit Chance",
	"crit_mult": "Crit Mult",
	"physical": "Physical Power",
	"poison": "Poison Power",
	"fire": "Fire Power",
	"ice": "Ice Power",
	"physical_resist": "Physical Resist",
	"poison_resist": "Poison Resist",
	"fire_resist": "Fire Resist",
	"ice_resist": "Ice Resist"
}
