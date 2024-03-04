extends Node

signal consume_teleport
signal consume_health
signal consume_invisibility

export var health_potion_amount = 25

var CONSUMABLE_TYPES = {
	"teleport": {
		"name": "Teleport Potion",
		"description": "Skip the current encounter.",
		"sprite": preload("res://graphics/consumables/magic-portal.svg"),
		"color": Color("#a300ff"),
		"start_count": 5
	},
	"health": {
		"name": "Health Potion",
		"description": "Heal {0} health.".format([health_potion_amount]),
		"sprite": preload("res://graphics/consumables/heart-bottle.svg"),
		"color": Color("#00ca67"),
		"start_count": 2
	},
	"invisibility": {
		"name": "Invisibility Potion",
		"description": "Sneak past enemies to grab rewards.",
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
		better_button.align = 2
		better_button.valign = 2
		better_button.font_size = 24
		
		get_node("%InventoryInner").add_child(better_button)
		var size = 64
		better_button.rect_min_size = Vector2(size,size)
		better_button.rect_size = Vector2(size,size)
		better_button.connect("pressed",self,"use_consumable", [c])
		better_button.connect("mouse_entered",self,"hover_button", [config])
		better_button.connect("mouse_exited",self,"unhover_button", [config])
		unhover_button(config)

# TODO: make this work
func hover_button(config):
	config.button.self_modulate = Color(1,1,1)
	get_node("%ConsumableTooltip").text = config.name + ": " +config.description
	
func unhover_button(config):
	config.button.self_modulate = config.color
	get_node("%ConsumableTooltip").text = ""
	
func use_consumable(type: String):
	print("pressed")
	if consumable_inventory[type] > 0:	
		consumable_inventory[type] = consumable_inventory[type]-1
		emit_signal("consume_"+type)
	
func _process(delta):
	for c in CONSUMABLE_TYPES:
		var config = CONSUMABLE_TYPES[c]
		config.button.text = "{0}".format([consumable_inventory[c]])
		config.button.visible = consumable_inventory[c] > 0

