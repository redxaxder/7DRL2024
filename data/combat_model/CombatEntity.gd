extends Resource

class_name CombatEntity

#useful constants
const chance_denom: float = 100.0
const damage_fudge: float = 0.75

# stats that don't change often
var stats: StatBlock
var faction: int
var entity_index: int # duplicated from driver
var actor_type: int
var actions: Array
var reactions: Array
var name: String
var element: int = Elements.Kind.Physical

# stats that do
var cur_hp: int
var location: Vector2 # duplicated from driver
var time_spent: int

func initialize(brawn: int, brains: int, guts: int, eyesight: int, footwork: int, hustle: int, _faction: int, moniker: String):
	stats = StatBlock.new()
	stats.initialize(brawn, brains, guts, eyesight, footwork, hustle)
	cur_hp = stats.max_hp()
	assert(cur_hp > 0)
	faction = _faction
	name = moniker

func is_alive():
	return (cur_hp > 0)

func pass_time(t: int):
	time_spent += t
	for a in actions:
		a.cool(t)
	for a in reactions:
		a.cool(t)

func initialize_with_block(_stats: StatBlock, _faction: int, moniker: String):
	stats = DataUtil.deep_dup(_stats)
	cur_hp = stats.max_hp()
	assert(cur_hp > 0)
	faction = _faction
	name = moniker

func chance_to_hit_other(other: CombatEntity) -> float:
	#example: self accuracy 10, other evasion 8
	# chance to hit is 1 - 1 / 100 = .99
	#example: self accuracy 10, other evasion 12
	# chance to hit is 1 - abs(5 - 12) / 100 = .93
	#example: self accuracy, other evasion 20
	# chance to hit is 1 - abs(5 - 20) / 100 = .85
	var numerator: float = 1.0
	if stats.accuracy() < other.stats.evasion():
		numerator = float(stats.accuracy()) / 2.0 - float(stats.evasion())
	return 1.0 - numerator / chance_denom
	
func basic_attack_damage_to_other(other: CombatEntity) -> Array:
	#example: self damage is 10, other evasion 8
	# damage range is (6, 8)
	#example: self damage is 10, other evasion 12
	# damage range is (4, 7)
	#example: self damage is 10, other evasion 12
	# damage range is (4, 7)
	#example: self damage is 10, other evasion 20
	# damage range is (0, 5)
	var max_damage = (stats.damage() - float(other.stats.evasion()) / 4.0) * damage_fudge
	var min_damage = (stats.damage() - float(other.stats.evasion()) / 2.0) * damage_fudge
	max_damage = int(max(max_damage, 0))
	min_damage = int(max(min_damage, 0))
	return [min_damage, max_damage]
	
func element_resist_multiplier(damage_type: int) -> float:
	var resist_stat = Elements.DEFENSE[damage_type]
	var resist = stats.get_modified_stat(resist_stat)
	var modifier = 100 - min(resist, Elements.MAX_RESIST)
	return float(modifier) / 100.0

func append_bonus(skill: Bonus):
	stats.bonuses.append(skill)
	
func append_ability(skill: Ability):
	match skill.activation.trigger:
		SkillsCore.Trigger.Action:
			actions.append(skill)
		SkillsCore.Trigger.Automatic:
			reactions.append(skill)

func event_reactions() -> Array:
	return reactions
