extends Control

export var skill_tree: Resource = SkillTree.new()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var selected_skill : Skill

# Called when the node enters the scene tree for the first time.
func _ready():
			
	var skill_names = [
		"Aphotic Reach",
		"Draconic Assailment",
		"Modest Beheading",
		"Inscrutable Strike",
		"Disgrace of the World",
		"Dementia against Greed",
		"Slaughter against Strength",
		"Miraculous Luck",
		"Hangman's Starve",
		"Monster's Edge",
		"Serpent's Stone",
		"Devil's Tomorrow",
		"Burly Assault",
		"Poisonous Shout",
		"Mastadon's Burly Glory",
	]
	
	for i in skill_tree.skillsPerRow:
		skill_tree.skills.append([])
		for j in skill_tree.numRows:
			var skill = skill_tree.addSkill(skill_names[i*skill_tree.numRows + j], i, j)
			print(skill)
			var button = Button.new()
			button.connect("pressed", self, 'selectSkill', [skill])
			button.add_stylebox_override('normal', preload("res://new_styleboxflat.tres"))
			$VBoxContainer/GridContainer.add_child(button)
			button.rect_min_size = Vector2(100, 100)
			print(button.rect_min_size)
			
	$VBoxContainer/UnlockButton.visible = false
	$VBoxContainer/UnlockButton.connect("pressed", self, 'unlockSkill', [])

func _draw():
	
	# todo:
	#	x	-populate text area with skill tree description
	# 	-style button differently if it is 
	#	-move skill generator out of view
	# 	-general cleanup
	# 	-push
	
	# TODO:
	# 	-draw lines between skills
	# 	-draw buttons as circles?
	
	
	
	for i in skill_tree.skillsPerRow:
		for j in skill_tree.numRows:
			var skill = skill_tree.skills[i][j]
			var button : Control = $VBoxContainer/GridContainer.get_child(i*skill_tree.numRows + j)
			button.text = skill.name[0]
				
	
#	var dark_sage = Color("#50727B")
#	var sage = Color("#78A083")
#	var navy = Color("#35374B")
#	var radius: float = 10
#	var spacing: float = radius * 4
#	for i in skill_tree.skillsPerRow:
#		for j in skill_tree.numRows:
#			print(skill_tree.skills[i][j].name)
#			var color = dark_sage if (i+j) % 2 == 0 else sage
#			# node outline 
#			draw_circle(Vector2(spacing*(i+1), spacing*(j+1)), radius + 3, navy)
#			# node circle
#			draw_circle(Vector2(spacing*(i+1), spacing*(j+1)), radius, color)

	
	print('in draw')

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func selectSkill(skill: Skill):
	selected_skill = skill
	$VBoxContainer/SkillName.text = skill.name
	$VBoxContainer/SkillDescription.text = "Lorem ipsum"
	$VBoxContainer/UnlockButton.visible = true
	
func unlockSkill():
	print("unlock skill: "+selected_skill.name)
