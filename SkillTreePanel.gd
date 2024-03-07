extends PanelContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("%ViewSkillTree").connect("skill_unlocked",self,"update_skill_points")
	print("connected skill unlocked")
	
func update_skill_points():
	print("update skill points in panel")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
