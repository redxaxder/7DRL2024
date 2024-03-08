extends Resource

class_name Skill

enum Kind {Ability, Bonus}
export var kind: int
export var name: String
export var ability: Resource = null # Ability
export var bonuses: Array = [] # Array of Bonus

func generate_description(stats: StatBlock) -> String:
	match kind:
		Kind.Ability:
			return ability.generate_description(stats)
		Kind.Bonus:
			return Bonus.generate_bonus_description(bonuses)
	assert(false)
	return "Error: no description"

func get_color():
	if kind == Kind.Bonus:
		return Color("#b700ff")
	if ability:
		return ability.get_color()
	return RandomUtil.color_hash(name)


const STAT_PREMIUM = { \
	Stat.Kind.Brawn: 1,
	Stat.Kind.Brains: 1,
	Stat.Kind.Guts: 1,
	Stat.Kind.Eyesight: 1,
	Stat.Kind.Footwork: 1,
	Stat.Kind.Hustle: 1,
	Stat.Kind.Accuracy: 3,
	Stat.Kind.Crit: 3,
	Stat.Kind.Evasion: 3,
	Stat.Kind.Damage: 3,
	Stat.Kind.Speed: 3,
	Stat.Kind.Health: 3,
	Stat.Kind.Physical: 2,
	Stat.Kind.Fire: 2,
	Stat.Kind.Ice: 2,
	Stat.Kind.Poison: 2,
	Stat.Kind.PhysicalResist: 3,
	Stat.Kind.FireResist: 5,
	Stat.Kind.IceResist: 5,
	Stat.Kind.PoisonResist: 5,
}
static func random_bonus(skill_seed: int) -> Array:
	var rng = RandomNumberGenerator.new()
	rng.seed = skill_seed
	var plus = Bonus.new()
	var magnitude = rng.randi() % 4
	var variance = (rng.randf() - 0.5) /6
	var power = (1 + magnitude) * 10 * (1+ variance)
	plus.stat = rng.randi() % Stat.Kind.MAX
	plus.power = power * STAT_PREMIUM[plus.stat]
	if magnitude == 0: return [plus]
	var minus = Bonus.new()
	var minus_stats = []
	for s in Stat.Kind.MAX:
		if s == plus.stat: continue
		if Stat.MINIMUM[s] == 0: continue
		minus_stats.append(s)
	minus.stat = minus_stats[rng.randi() % minus_stats.size()]
	minus.power = plus.power * -0.5
	minus.power *= STAT_PREMIUM[minus.stat]
	return  [plus, minus]




static func random_ability(skill_seed: int) -> Ability:
	var rng = RandomNumberGenerator.new()
	rng.seed = skill_seed
#	var scaling = random_mods(rng.randi())
	var a = Ability.new()
	
	
	# match effect element to effect stat in buff/debuff
	
	# the effect
	var eff: Effect = Effect.new()
#export var effect_type: int # damage or statbuff
#export var mod_stat: int = -1 # if this is a buff/debuff, which stat is affected?
#export var power: int # damage amount or buff amount or summon unit id
#export var element: int = Elements.Kind.Physical
	#export var targets: int = SkillsCore.Target.Enemies
	eff.targets = SkillsCore.Target.Enemies if rng.randf() < 0.7 \
		else SkillsCore.Target.Self if rng.randf() < 0.9 \
		else SkillsCore.TargetAny
	
	eff.element = rng.randi() % Elements.Kind.MAX
	var power: float = (rng.randf() + rng.randf() + rng.randf())
	match eff.targets:
		SkillsCore.Target.Self:
			eff.effect_type = SkillsCore.EffectType.StatBuff
		SkillsCore.Target.Enemies:
			eff.effect_type = SkillsCore.EffectType.Damage if rng.randf() < 0.7 \
							else SkillsCore.EffectType.StatBuff
			if eff.effect_type == SkillsCore.EffectType.StatBuff:
				power *= -1
		SkillsCore.Target.TargetAny:
			eff.effect_type = SkillsCore.EffectType.Damage if rng.randf() < 0.2 \
				else SkillsCore.EffectType.StatBuff
			if eff.effect_type == SkillsCore.EffectType.StatBuff and rng.randf() < 0.5:
				power *= -1
	if eff.effect_type == SkillsCore.EffectType.StatBuff:
		if rng.randf() < 0.6: # a main combat stat
			eff.mod_stat = Stat.DERIVED_STATS[ rng.randi() % Stat.DERIVED_STATS.size() ]
		elif power > 0: #elemental attack or defense
			eff.mod_stat = Elements.ATTACK[eff.element] if rng.randf() < 0.8 \
						else Elements.DEFENSE[eff.element]
		else: # if power is negative, we only hit elemental defense
			eff.mod_stat = Elements.DEFENSE[eff.element]
		power *= STAT_PREMIUM[eff.mod_stat] * 0.6
	
	
	var act: Activation = Activation.new()
	if rng.randf() < 1: #0.5:
		act.trigger = SkillsCore.Trigger.Action
		power += 3*sign(power)
		var mod_table = [	Ability.ModParam.CooldownTime,
							Ability.ModParam.Power]
		if !(eff.targets == SkillsCore.Target.Self):
			mod_table.append(Ability.ModParam.AbilityRange)
			mod_table.append(Ability.ModParam.Radius)
		var rolls = []
		var n = mod_table.size()
		rolls.resize(n)
		rolls.fill(0)

		var num_rolls = 6
		var num_mods = 0
	
		if rng.randf() < 0.3:
			num_rolls += 4
		elif rng.randf() < 0.4:
			num_rolls += 1
			num_mods = 1
		else:
			num_mods = 2

		a.modifiers = []
		for _i in num_mods:
			var mod_param = mod_table[rng.randi() % n]
			var mod_stat = rng.randi() % 6
			if a.modifiers.size() > 0 and a.modifiers[0].modified_param == mod_param:
				num_rolls += 1
				break
			a.modifiers.append(Ability.mod(mod_stat, mod_param, 4))

		for _i in num_rolls:
			rolls[rng.randi() % n] += 1
		for i in n:
			var rolled = rolls[i]
			match mod_table[i]:
				Ability.ModParam.CooldownTime:
					act.cooldown_time = 90 / (rolled + 1)
				Ability.ModParam.Power:
					power *= pow(1.15, rolled)
				Ability.ModParam.AbilityRange:
					act.ability_range = rolled
				Ability.ModParam.Radius:
					act.radius = ceil(float(rolled) /2)
		if eff.targets == SkillsCore.Target.Self:
			act.ability_range = 0
		elif act.radius == 0:
			act.ability_range += 1
#			var mod = Ability.mod(mod_stat, mod_param, coeff)
		
#		# radius, range, cooldown, power
#		for _i in 6:
#			if
	else: 
		act.trigger = SkillsCore.Trigger.Automatic
		act.filter = rng.randi() % Activation.Filter.MAX
		act.cooldown_time = 1
		power *= TRIGGER_PREMIUM[act.filter]
		#TODO

	eff.power = int(power)
	a.activation = act
	a.effect = eff
	return a

# extra stuff for things that activate rarely
const TRIGGER_PREMIUM = {
	Activation.Filter.DamageDealt: 1, 
	Activation.Filter.DamageReceived: 3,
	Activation.Filter.Death: 5,
	Activation.Filter.Movement: 1,
	Activation.Filter.Start: 10,
	Activation.Filter.Bloodied: 20,
	Activation.Filter.Miss: 5,
	Activation.Filter.Dodge: 5,
	Activation.Filter.Attack: 5,
	}

