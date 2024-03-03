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

# stats that do
var cur_hp: int
var location: Vector2 # duplicated from driver
var time_spent: int

func initialize(brawn: int, brains: int, guts: int, eyesight: int, footwork: int, hustle: int, _faction: int):
	stats = StatBlock.new()
	stats.initialize(brawn, brains, guts, eyesight, footwork, hustle)
	cur_hp = stats.max_hp()
	faction = _faction

func is_alive():
	return (cur_hp > 0)

func initialize_with_block(_stats: StatBlock, _faction: int):
	stats = _stats
	cur_hp = stats.max_hp()
	faction = _faction

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

func acquire_bonus(skill: Skill):
	assert(skill.kind == Skill.SkillKind.Bonus)
	assert(skill.bonus_kind != Skill.BonusKind.None)
	stats.bonuses.append(skill)
