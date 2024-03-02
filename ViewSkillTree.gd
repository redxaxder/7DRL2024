extends Control

export var skill_tree: Resource = SkillTree.new()

var selected_skill : Skill
var unlocked_skills: Dictionary
var available_skills: Dictionary

func _ready():
	unlocked_skills = {}
	
	# TODO: generated skill names
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
		for i in skill_tree.skillsPerRow:
			var skill = skill_tree.addSkill(skill_names[j*skill_tree.skillsPerRow + i], i, j)
			print(skill)
			var button = Button.new()
			button.connect("pressed", self, 'selectSkill', [skill, button])
			$VBoxContainer/GridContainer.add_child(button)
			button.rect_min_size = Vector2(100, 100)
			print(button.rect_min_size)
			
	$VBoxContainer/UnlockButton.visible = false
	$VBoxContainer/UnlockButton.connect("pressed", self, 'unlockSkill', [])
	
	# make available first two columns
	for i in 2:
		for j in skill_tree.numRows:
			markSkillAvailable(i, j)

func _draw():
	# TODO:
	#	-move skill creation to separate class?
	# 	-draw lines between skills
	# 	-draw buttons as circles
	
	for i in skill_tree.skillsPerRow:
		for j in skill_tree.numRows:
			var skill : Skill = skill_tree.skills[i][j]
			var buttonIndex = j*skill_tree.skillsPerRow + i
			var button : Control = $VBoxContainer/GridContainer.get_child(buttonIndex)
			button.text = skill.name[0]
			
			if(unlocked_skills.has(skill.name)):
				drawButtonUnlocked(button)
			elif(available_skills.has(skill.name)):
				drawButtonAvailable(button)
			else:
				drawButtonDefault(button)
				
func drawButtonUnlocked(button: Button):
	button.add_stylebox_override('normal', preload("res://style_unlocked.tres"))
	button.add_stylebox_override('hover', preload("res://style_unlocked.tres"))
	button.add_stylebox_override('pressed', preload("res://style_unlocked.tres"))
	
func drawButtonAvailable(button: Button):
	button.add_stylebox_override('normal', preload("res://style_available.tres"))
	button.add_stylebox_override('hover', preload("res://style_available.tres"))
	button.add_stylebox_override('pressed', preload("res://style_available.tres"))

func drawButtonSelected(button: Button):
	button.add_stylebox_override('normal', preload("res://style_selected.tres"))
	button.add_stylebox_override('hover', preload("res://style_selected.tres"))
	button.add_stylebox_override('pressed', preload("res://style_selected.tres"))
	
func drawButtonDefault(button: Button):
	button.add_stylebox_override('normal', preload("res://style_default.tres"))
	button.add_stylebox_override('hover', preload("res://style_default.tres"))
	button.add_stylebox_override('pressed', preload("res://style_default.tres"))
	
	
			
	# circle drawing code (maybe use this instead of buttons?):
	
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func selectSkill(skill: Skill, button: Button = null):
	selected_skill = skill
	$VBoxContainer/SkillName.text = skill.name
	$VBoxContainer/SkillDescription.text = "Lorem ipsum"
		
	$VBoxContainer/UnlockButton.visible = !unlocked_skills.has(skill.name)
	
	if(button):
		_draw()
		drawButtonSelected(button)
	
func markSkillAvailable(i: int, j: int):
	if(i<0 || i >= skill_tree.skillsPerRow ||
	j<0 || j >= skill_tree.numRows):
		return
	var neighbor_skill = skill_tree.skills[i][j]
	available_skills[neighbor_skill.name] = true
	
func unlockSkill():
	for i in skill_tree.skillsPerRow:
		for j in skill_tree.numRows:
			if(selected_skill.name == skill_tree.skills[i][j].name):
				markSkillAvailable(i+1,j)
				markSkillAvailable(i+2,j)
				markSkillAvailable(i,j-1)
				markSkillAvailable(i,j+1)
	unlocked_skills[selected_skill.name] = true
	selectSkill(selected_skill)
	_draw()
