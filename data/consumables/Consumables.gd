extends Node

signal consume_teleport
signal consume_health
signal consume_invisibility

export var health_potion_amount = 25

var rewards = []
var won_rewards = [];

var CONSUMABLE_TYPES = {
	"teleport": {
		"name": "Teleport Potion",
		"description": "Skip the current encounter.",
		"sprite": preload("res://graphics/consumables/magic-portal.svg"),
		"color": Color("#a300ff"),
		"start_count": 50
	},
	"health": {
		"name": "Health Potion",
		"description": "Heal {0} health.".format([health_potion_amount]),
		"sprite": preload("res://graphics/consumables/heart-bottle.svg"),
		"color": Color("#00ca67"),
		"start_count": 0
	},
	"invisibility": {
		"name": "Invisibility Potion",
		"description": "Sneak past enemies to grab rewards.",
		"sprite": preload("res://graphics/consumables/cowled.svg"),
		"color": Color("#5b583e"),
		"start_count": 0
	}
}

var consumable_inventory = {}

func _ready():
	
	var bb = preload("res://misc/BetterButton.tscn")
	for c in CONSUMABLE_TYPES:
		var config = CONSUMABLE_TYPES[c]
		
		config.shake = 0
		
		var better_button = bb.instance()
		
		config.button = better_button
		
		better_button.text = ""
		better_button.image = config.sprite
		better_button.align = 2
		better_button.valign = 2
		better_button.font_size = 24
		
		var size = 64
		
		var control = Control.new()
		get_node("%InventoryInner").add_child(control)
		control.rect_min_size = Vector2(size,size)
		control.rect_size = Vector2(size,size)
		control.add_child(better_button)
		# button size must be set after control size
		better_button.rect_min_size = Vector2(size,size)
		better_button.rect_size = Vector2(size,size)
		
		better_button.connect("pressed",self,"use_consumable", [c])
		better_button.connect("mouse_entered",self,"hover_button", [config, better_button])
		better_button.connect("mouse_exited",self,"unhover_button", [config, better_button])
		unhover_button(config, better_button)

func win_rewards():
	won_rewards = DataUtil.dup_array(rewards)
	pass
		
func transfer_reward():
	var r = won_rewards.pop_back()
	if(r):	
		print("transfer_reward type"+r)
		consumable_inventory[r] += 1
		CONSUMABLE_TYPES[r].shake = 30
		
func init_rewards():
	var children = get_node("%Rewards").get_children()
	for c in children:
		c.queue_free()
	
	# create random 
	var r = randf()
	var num_rewards
	if(r < .02): 			#  2% => 3
		num_rewards = 3
	elif(r < .2): 			# 19% => 2
		num_rewards = 2
	else:			 		# 80% => 1
		num_rewards = 1
		
	rewards = []
	
	var reward_counts = {}
		
	for i in num_rewards:
		var type = DataUtil.pick([
			"teleport",
			"teleport",
			"teleport",
			"teleport",
			"teleport",
			"teleport",
			"health",
			"health",
			"health",
			"invisibility"
		])
		if(!rewards.has(type)):
			reward_counts[type] = 1
		else:
			reward_counts[type] += 1
	
	var bb = preload("res://misc/BetterButton.tscn")
	for c in reward_counts:
		rewards.append(c)
		var config = CONSUMABLE_TYPES[c]
		var count = reward_counts[c]
		var better_button = bb.instance()
		
		better_button.text = "" if count == 1 else str(count)
		better_button.image = config.sprite
		better_button.align = 2
		better_button.valign = 2
		better_button.font_size = 24
		
		var size = 64
		
		
		
		better_button.self_modulate = config.color
		
		
		var control = Control.new()
		get_node("%Rewards").add_child(control)
		control.rect_min_size = Vector2(size,size)
		control.rect_size = Vector2(size,size)
		control.add_child(better_button)
		# button size must be set after control size
		better_button.rect_min_size = Vector2(size,size)
		better_button.rect_size = Vector2(size,size)
		


		
		
		
		
		better_button.set_anchors_preset(Control.PRESET_WIDE)
		
		
		better_button.connect("mouse_entered",self,"hover_button", [config, better_button])
		better_button.connect("mouse_exited",self,"unhover_button", [config, better_button])
		
		unhover_button(config, better_button)
		
func init_starting_consumables():
	for c in CONSUMABLE_TYPES:
		consumable_inventory[c] = CONSUMABLE_TYPES[c].start_count
		
	rewards = []
	won_rewards = []

# TODO: make this work
func hover_button(config, button):
	button.self_modulate = Color(1,1,1)
	get_node("%ConsumableTooltip").text = config.name + ": " +config.description
	get_node("%ConsumableTooltip").visible = true
	
func unhover_button(config, button):
	button.self_modulate = config.color
	get_node("%ConsumableTooltip").text = ""
	get_node("%ConsumableTooltip").visible = false
	
func use_consumable(type: String):
	if consumable_inventory[type] > 0:	
		var config = CONSUMABLE_TYPES[type]
		consumable_inventory[type] = consumable_inventory[type]-1
		emit_signal("consume_"+type)
		unhover_button(CONSUMABLE_TYPES[type], config.button)
	
func _process(_delta):
	for c in CONSUMABLE_TYPES:
		var config = CONSUMABLE_TYPES[c]
		config.button.text = "{0}".format([consumable_inventory[c]])
		config.button.visible = consumable_inventory[c] > 0
		config.shake *= 0.9
		
		if(config.shake < 1):
			config.shake = 0
		config.button.rect_position =Vector2(
			(randf()-0.5)*config.shake,
			(randf()-0.5)*config.shake
		)
#		config.button.rect_position = Vector2.ZERO
