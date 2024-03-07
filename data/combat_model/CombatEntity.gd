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
var last_used_time: Dictionary = {}
var name: String
var element: int = Elements.Kind.Physical

# stats that do
var cur_hp: int
var location: Vector2 # duplicated from driver
var time_spent: float

func initialize(brawn: int, brains: int, guts: int, eyesight: int, footwork: int, hustle: int, _faction: int, moniker: String):
	stats = StatBlock.new()
	stats.initialize(brawn, brains, guts, eyesight, footwork, hustle)
	cur_hp = stats.max_hp()
	assert(cur_hp > 0)
	faction = _faction
	name = moniker

func can_use_ability(a: Ability, when: float) -> bool:
	var last_used = last_used_time.get(a.name)
	if last_used == null: return true
	return (when - last_used) >= a.cooldown_time(stats)

func mark_ability_use(a: Ability, when: float):
	assert(when >= last_used_time.get(a.name, 0), "using ability before cooldown is up is not allowed")
	last_used_time[a.name] = when

func is_alive():
	return (cur_hp > 0)

func pass_time(t: float):
	time_spent += t

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
	var resist = float(stats.get_modified_stat(resist_stat))
	if resist >= 0:
		return 100.0 / (100.0 + resist)
	else:
		return 2.0 - (100 / (100 - resist))

func append_bonus(bonus: Bonus):
	stats.apply_bonus(bonus)
	
func append_ability(ability: Ability):
	match ability.activation.trigger:
		SkillsCore.Trigger.Action:
			actions.append(ability)
		SkillsCore.Trigger.Automatic:
			reactions.append(ability)

func event_reactions() -> Array:
	return reactions
