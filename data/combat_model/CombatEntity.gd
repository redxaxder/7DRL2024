extends Resource

class_name CombatEntity

#useful constants
const chance_denom: float = 100.0

# stats that don't change often
var stats: StatBlock
var faction: int
var entity_index: int # duplicated from driver

var actor_type: int

# stats that do
var cur_hp: int
var location: Vector2 # duplicated from driver
var time_spent: int

func initialize(brawn: int, brains: int, guts: int, eyesight: int, footwork: int, hustle: int, faction: int):
	stats = StatBlock.new()
	stats.initialize(brawn, brains, guts, eyesight, footwork, hustle)
	cur_hp = stats.max_hp()
	self.faction = faction

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
	var max_damage: int = max(stats.damage() - float(other.stats.evasion()) / 4.0, 0)
	var min_damage: int = max(stats.damage() - float(other.stats.evasion()) / 2.0, 0)
	return [min_damage, max_damage]
