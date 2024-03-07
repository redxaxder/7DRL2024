extends Control

export var skill_tree: Resource

var num_skills_to_unlock: int = 0
var player_stats: StatBlock
var selected_skill : Skill
var unlocked_skills: Dictionary
var containers: Array



# approximately follows the curve level=unlocks^2.1073
# the first point is unlocked at level 1. the second at level 5, and so on
# 8 skills unlock total
const unlock_thresholds = [1,5,11,19,30,44,61,80]

func _ready():
	unlocked_skills = {}
	
#	var skill_names = [
#		"Aphotic Reach",
#		"Draconic Assailment",
#		"Modest Beheading",
#		"Inscrutable Strike",
#		"Disgrace of the World",
#		"Dementia against Greed",
#		"Slaughter against Strength",
#		"Miraculous Luck",
#		"Hangman's Starve",
#		"Monster's Edge",
#		"Serpent's Stone",
#		"Devil's Tomorrow",
#		"Burly Assault",
#		"Poisonous Shout",
#		"Mastadon's Burly Glory",
#	]
	
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
	for container in containers:
		for button in container.get_children():
			button.queue_free()
	skill_tree = st
	for i in skill_tree.skills.size():
		for j in skill_tree.skills[i].size():
			var skill = skill_tree.skills[i][j]
#			var skill = skill_tree.addSkill(skill_names[j*skill_tree.skillsPerRow + i], i, j)
			var button = preload("res://graphics/random_icon.tscn").instance()
			button.connect("pressed", self, 'selectSkill', [skill, button])
			button.set_input(skill.name)
			containers[i].add_child(button)
			button.rect_min_size = Vector2(80, 80)
			
	
	# make available first two columns
	for i in skill_tree.skills.size():
		for j in skill_tree.skills[i].size():
			pass
#			markSkillAvailable(i, j)

func _draw():
	# TODO:
	#	-move skill creation to separate class?
	# 	-draw lines between skills
	# 	-draw buttons as circles
	
	for i in skill_tree.skills.size():
		for j in skill_tree.skills[i].size():
			var skill : Skill = skill_tree.skills[i][j]
			var button = containers[i].get_child(j)
			
			if skill == selected_skill:
				drawButtonSelected(button)
			else:
				drawButtonUnselected(button)
				
			if(unlocked_skills.has(skill.name)):
				drawButtonUnlocked(button, skill.name)
			elif(is_available(skill)):
				drawButtonAvailable(button)
			else:
				drawButtonUnavailable(button)
				
func drawButtonUnlocked(button: Button, skill_name : String):
	button.modulate = RandomUtil.color_hash(skill_name)
	
func drawButtonAvailable(button: Button):
	button.modulate = Color.white
	
func drawButtonUnavailable(button: Button):
	button.modulate = Color("#555")
	
func drawButtonSelected(button: Button):
	button.add_stylebox_override('normal', preload("res://style_selected.tres"))
	button.add_stylebox_override('hover', preload("res://style_selected.tres"))
	button.add_stylebox_override('pressed', preload("res://style_selected.tres"))
	
func drawButtonUnselected(button: Button):
	button.add_stylebox_override('normal', preload("res://style_default.tres"))
	button.add_stylebox_override('hover', preload("res://style_default.tres"))
	button.add_stylebox_override('pressed', preload("res://style_default.tres"))
	
	

func selectSkill(skill: Skill, button: Button = null):
	selected_skill = skill
	$VBoxContainer/SkillName.text = skill.name
	$VBoxContainer/ScrollContainer/SkillDescription.text = skill.generate_description(player_stats)
	update_unlock_button()
	
	if(button):
		_draw()
		
func get_skill_tree_location(skill: Skill) -> Vector2:
	for i in skill_tree.skills.size():
		for j in skill_tree.skills[i].size():
			if skill == skill_tree.skills[i][j]:
				return Vector2(i,j)
	return Vector2(-1,-1)
	

func is_available(skill: Skill):
	var loc = get_skill_tree_location(skill)
	if(loc.y == 0):
		return true
		
	var neighbors = [
		Vector2(0,-1),
		Vector2(0,-2),
		Vector2(-1,0),
		Vector2(1,0),
	]
	for n in neighbors:
		var neighbor = get_skill(loc.x + n.x, loc.y + n.y)
		print(neighbor)
		if neighbor && unlocked_skills.has(neighbor.name):
			print("skill available: " + skill.name)
			return true
	return false
	

func update_unlock_button():
	$VBoxContainer/UnlockButton.visible = !unlocked_skills.has(skill.name) && is_available(skill) && num_skills_to_unlock > 0


func get_skill(i: int, j: int) -> Skill:
	if i < 0 or i >= skill_tree.skills.size(): return null
	var row = skill_tree.skills[i]
	if j<0 or j >= row.size(): return null
	return row[j]

	
func unlockSkill():
	if is_available(selected_skill):
		unlocked_skills[selected_skill.name] = true
		selectSkill(selected_skill)
		skill_tree.unlock(selected_skill)
		recalculate_player_bonuses()
		_draw()
	
func recalculate_player_bonuses():
	player_stats.clear_bonuses()
	for skill in skill_tree.unlocks:
		if skill.kind == Skill.Kind.Bonus:
			player_stats.apply_bonus(skill.bonus)

func update_num_skills_to_unlock(progress: int):
	num_skills_to_unlock = total_skills_to_unlock(progress) - unlocked_skills.keys().size()
	update_unlock_button()

func total_skills_to_unlock(progress: int) -> int:
	var i = 0
	var n = unlock_thresholds.size()
	while unlock_thresholds[i] <= progress and i < n:
		i += 1
	return i

