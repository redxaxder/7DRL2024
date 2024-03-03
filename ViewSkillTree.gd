extends Control

export var skill_tree: Resource

var selected_skill : Skill
var unlocked_skills: Dictionary
var available_skills: Dictionary
var containers: Array

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
	
#	for i in skill_tree.skillsPerRow:
#		skill_tree.skills.append([])
#
	containers.append($VBoxContainer/SkillRow1)
	containers.append($VBoxContainer/SkillRow2)
	containers.append($VBoxContainer/SkillRow3)
	$VBoxContainer/UnlockButton.visible = false
# warning-ignore:return_value_discarded
	$VBoxContainer/UnlockButton.connect("pressed", self, 'unlockSkill', [])

func set_skills(st: SkillTree):
	selected_skill = null
	unlocked_skills = {}
	available_skills = {}
	for container in containers:
		for button in container.get_children():
			button.queue_free()
	skill_tree = st
	for i in skill_tree.skills.size():
		for j in skill_tree.skills[i].size():
			var skill = skill_tree.skills[i][j]
#			var skill = skill_tree.addSkill(skill_names[j*skill_tree.skillsPerRow + i], i, j)
			print(skill)
			var button = Button.new()
			button.connect("pressed", self, 'selectSkill', [skill, button])
			containers[i].add_child(button)
#			$VBoxContainer/GridContainer.add_child(button)
			button.rect_min_size = Vector2(100, 100)
			print(button.rect_min_size)
	
	# make available first two columns
	for i in skill_tree.skills.size():
		for j in skill_tree.skills[i].size():
			markSkillAvailable(i, j)

func _draw():
	# TODO:
	#	-move skill creation to separate class?
	# 	-draw lines between skills
	# 	-draw buttons as circles
	
	for i in skill_tree.skills.size():
		for j in skill_tree.skills[i].size():
			var skill : Skill = skill_tree.skills[i][j]
#			var buttonIndex = j*skill_tree.skills[i].size() + i
#			var button : Control = $VBoxContainer/GridContainer.get_child(buttonIndex)
			var button = containers[i].get_child(j)
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
	

func get_skill(i: int, j: int) -> Skill:
	if i < 0 or i >= skill_tree.skills.size(): return null
	var row = skill_tree.skills[i]
	if j<0 or j >= row.size(): return null
	return row[j]

func markSkillAvailable(i: int, j: int):
	var neighbor_skill = get_skill(i,j)
	if neighbor_skill:
		available_skills[neighbor_skill.name] = true
	
func unlockSkill():
	for i in skill_tree.skills.size():
		for j in skill_tree.skills[i].size():
			if(selected_skill.name == skill_tree.skills[i][j].name):
				markSkillAvailable(i+1,j)
				markSkillAvailable(i+2,j)
				markSkillAvailable(i,j-1)
				markSkillAvailable(i,j+1)
	unlocked_skills[selected_skill.name] = true
	selectSkill(selected_skill)
	skill_tree.unlock(selected_skill)
	_draw()
	
