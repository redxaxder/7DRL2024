extends Node

signal consume_teleport
signal consume_health
signal consume_invisibility

var CONSUMABLE_TYPES = {
	"teleport": {
		"name": "Teleport Potion",
		"sprite": preload("res://graphics/consumables/magic-portal.svg"),
		"color": Color("#a300ff"),
		"start_count": 5
	},
	"health": {
		"name": "Health Potion",
		"sprite": preload("res://graphics/consumables/heart-bottle.svg"),
		"color": Color("#00ca67"),
		"start_count": 2
	},
	"invisibility": {
		"name": "Invisibility Potion",
		"sprite": preload("res://graphics/consumables/cowled.svg"),
		"color": Color("#5b583e"),
		"start_count": 1
	}
}

var consumable_inventory = {}

func _ready():
	var bb = preload("res://misc/BetterButton.tscn")
	for c in CONSUMABLE_TYPES:
		var config = CONSUMABLE_TYPES[c]
		var better_button = bb.instance()
		
		config.button = better_button
		
		better_button.text = "4"
		consumable_inventory[c] = config.start_count
		better_button.image = config.sprite
		better_button.self_modulate = config.color
		better_button.align = 2
		better_button.valign = 2
		better_button.font_size = 24
		
		add_child(better_button)
		var size = 64
		better_button.rect_min_size = Vector2(size,size)
		better_button.rect_size = Vector2(size,size)
		better_button.connect("pressed",self,"use_consumable", [c])

	
func use_consumable(type: String):
	if consumable_inventory[type] > 0:	
		consumable_inventory[type] = consumable_inventory[type]-1
		emit_signal("consume_"+type)
	
func _process(delta):
	for c in CONSUMABLE_TYPES:
		var config = CONSUMABLE_TYPES[c]
		config.button.text = "{0}".format([consumable_inventory[c]])
		config.button.visible = consumable_inventory[c] > 0

