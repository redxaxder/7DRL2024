extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var CONSUMABLE_TYPES = {
	"teleport": {
		"name": "Teleport Potion",
		"sprite": preload("res://graphics/consumables/magic-portal.svg"),
		"color": Color("#a300ff")
	},
	"health": {
		"name": "Health Potion",
		"sprite": preload("res://graphics/consumables/heart-bottle.svg"),
		"color": Color("#00ca67")
	},
	"invisibility": {
		"name": "Invisibility Potion",
		"sprite": preload("res://graphics/consumables/cowled.svg"),
		"color": Color("#5b583e")
	}
}

func _ready():
	for c in CONSUMABLE_TYPES:
		var button = Button.new()
		var config = CONSUMABLE_TYPES[c]
		add_child(button)
		button.connect("pressed",self,"use_consumable", [c])
		button.icon = config.sprite
		button.self_modulate = config.color
		button.text = "fooo"
		button.rect_scale = Vector2(0.1, 0.1)
	
func use_consumable(type: String):
	print("use "+type)

