extends Control

signal skill_unlocked

export var skill_tree: Resource

var extra_skill_points : int = 0

var num_skills_to_unlock: int = 0
var progress: int = 0
var player_stats: StatBlock
var selected_skill : Skill
var clicked_skill: Skill
var unlocked_skills: Dictionary
var containers: Array

var reward_bonuses = []



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
	containers.append($SkillTreeContainer/SkillRow1)
	containers.append($SkillTreeContainer/SkillRow2)
	containers.append($SkillTreeContainer/SkillRow3)
	$SkillTreeContainer/UnlockButton.visible = false
# warning-ignore:return_value_discarded
	$SkillTreeContainer/UnlockButton.connect("pressed", self, 'unlockSkill', [])
	
	
	# get_node("%SkillTreeContainer").connect("mouse_exited", self, 'unhover_container', [])

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
			button.connect("pressed", self, 'click_skill', [skill, button])
			button.connect("mouse_entered", self, 'hover_button', [skill, button])
			button.connect("mouse_exited", self, 'unhover_button', [skill, button])
			button.set_input(skill)
			button.mouse_filter = Control.MOUSE_FILTER_PASS
			containers[i].add_child(button)
			button.rect_min_size = Vector2(80, 80)
			
	
	# make available first two columns
	for i in skill_tree.skills.size():
		for j in skill_tree.skills[i].size():
			pass
#			markSkillAvailable(i, j)

func hover_button(skill, button):
	selectSkill(skill, button)
	
func unhover_container():
	if clicked_skill:
		selectSkill(clicked_skill)
	_draw()
	
func unhover_button(skill, button):
	if clicked_skill:
		selectSkill(clicked_skill, button)

func click_skill(skill, button):
	clicked_skill = skill
	show_skill_description(skill, button)

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
				drawButtonUnlocked(button, skill)
			elif(is_available(skill)):
				drawButtonAvailable(button)
			else:
				drawButtonUnavailable(button)
				
			if skill == selected_skill && !unlocked_skills.has(skill.name):
				button.modulate = Color.white
				
func drawButtonUnlocked(button: Button, skill : Skill):
	button.modulate = skill.get_color()
	
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
	show_skill_description(skill, button)
	
		
func show_skill_description(skill: Skill, button: Button = null):
	$SkillTreeContainer/SkillName.text = skill.name
	$SkillTreeContainer/SkillName.modulate = skill.get_color()
	$SkillTreeContainer/SkillName.margin_left = 3
	$SkillTreeContainer/ScrollContainer/SkillDescription.text = ""
	$SkillTreeContainer/ScrollContainer/SkillDescription.bbcode_enabled = true
	$SkillTreeContainer/ScrollContainer/SkillDescription.append_bbcode(
		skill.generate_description(player_stats)
	)
	update_unlock_button(skill)
	
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
		if neighbor && unlocked_skills.has(neighbor.name):
			return true
	return false
	

func update_unlock_button(skill: Skill):
	$SkillTreeContainer/UnlockButton.visible = !unlocked_skills.has(skill.name) && is_available(skill) && num_skills_to_unlock > 0
	$SkillTreeContainer/UnlockButton['custom_colors/font_color'] = skill.get_color()


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
		update_num_skills_to_unlock(progress)
		emit_signal("skill_unlocked")
	
func set_reward_bonuses(p_reward_bonuses):
	reward_bonuses = p_reward_bonuses
	
func recalculate_player_bonuses():
	player_stats.clear_bonuses()
	
	# look up player stat bonuses from stats table
	var proto = Actor.STATS.get(Actor.Type.Player, null)
	if proto: for key in proto.keys():
		if typeof(key) == TYPE_INT:
			var bonus = Actor.bonus(key, proto.get(key))
			player_stats.apply_bonus(bonus)
	
	# add in skill tree unlock bonuses
	for skill in skill_tree.unlocks:
		if skill.kind == Skill.Kind.Bonus:
			for b in skill.bonuses:
				player_stats.apply_bonus(b)
			
	
	for b in reward_bonuses:
		player_stats.apply_bonus(b)
		
	update_stats(player_stats)
		
func update_stats(player_stats):
	var methods = [
		"Brawn", 
		"Brains", 
		"Guts", 
		"Eyesight", 
		"Footwork", 
		"Hustle", 
#
#		"max_hp", 
#		"damage", 
#		"speed",
#		"accuracy", 
#		"evasion",
#		"crit",
#		"crit_chance",
#		"crit_mult",
#		"physical", "fire", "poison", "ice",
#		"physical_resist", "fire_resist", "poison_resist", "ice_resist"
	]
	var dict = {}
	for k in methods: dict[k] = player_stats.call(k.to_lower())
	var stats_text = ""
	stats_text += "Stats:\n"
	stats_text += "------\n"
	for key in dict:
		stats_text += "{0}: {1}    ({2})\n".format([
			key,
			dict[key],
			player_stats.call(key.to_lower()+"_desc")
		])
	get_node("%Stats").text = stats_text

func update_num_skills_to_unlock(p_progress: int):
	progress = p_progress
	num_skills_to_unlock = extra_skill_points + total_skills_to_unlock(progress) - unlocked_skills.keys().size()
	#update_unlock_button()

func total_skills_to_unlock(progress: int) -> int:
	var i = 0
	var n = unlock_thresholds.size()
	while unlock_thresholds[i] <= progress and i < n:
		i += 1
		if(i>=n):
			break
	return i
	
func next_skill_point(progress: int):
	for u in unlock_thresholds:
		if u > progress:
			return  u

