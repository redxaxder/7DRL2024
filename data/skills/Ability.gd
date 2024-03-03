extends Resource

class_name Ability

# debuffs are just buffs with negative power

enum TargetKind {Self, Enemies, Allies, Any}
enum TriggerEffectKind {Damage, Activated} # TODO add more
enum AbilityEffectKind {Damage, Buff} # TODO add more
enum BuffKind {Brawn, Brains, Guts, Eyesight, Footwork, Hustle}
var trigger_target_kind
var trigger_effect_kind
var effect_kind
var power: int = 0
var effect_target_kind
var name: String = ""
var aoe_radius: int = 0 # 0 means single target
var ability_range: int = 1 # 1 means melee
var buff_kind
var cooldown: int = 0
var cooldown_max: int = 1

func initialize_ability(trigger_target, trigger_effect, ability_effect, apower: int, ability_target, aname: String, acooldown: int):
	trigger_target_kind = trigger_target
	trigger_effect_kind = trigger_effect
	effect_kind = ability_effect
	power = apower
	effect_target_kind = ability_target
	name = aname
	cooldown_max = acooldown

func on_cooldown() -> bool:
	return cooldown > 0
	
func cool():
	assert(cooldown > 0)
	cooldown -= 1

func use():
	assert(cooldown == 0)
	cooldown = cooldown_max

func generate_description() -> String:
	var abil_dict: Dictionary = {}
	var key = "trigger_target"
	match trigger_target_kind:
		TargetKind.Allies:
			abil_dict[key] = "an ally"
		TargetKind.Any:
			abil_dict[key] = "any creature"
		TargetKind.Enemies:
			abil_dict[key] = "an enemy"
		TargetKind.Self:
			abil_dict[key] = "you"
	key = "trigger_effect"
	match trigger_effect_kind:
		TriggerEffectKind.Activated:
			match trigger_target_kind:
				TargetKind.Self:
					abil_dict[key] = "activate this"
				_:
					abil_dict[key] = "wants to"
		TriggerEffectKind.Damage:
			match trigger_effect_kind:
				TargetKind.Self:
					abil_dict[key] = "sustain damage"
				_:
					abil_dict[key] = "takes damage"
	key = "ability_effect"
	match effect_kind:
		AbilityEffectKind.Buff:
			match buff_kind:
				BuffKind.Brawn:
					match effect_target_kind:
						TargetKind.Self:
							if power > 0:
								abil_dict[key] = "get more swole"
							else:
								abil_dict[key] = "get less swole"
						_:
							if power > 0:
								abil_dict[key] = "buff its Brawn"
							else:
								abil_dict[key] = "debuff its Brawn"
				BuffKind.Brains:
					match effect_target_kind:
						TargetKind.Self:
							if power > 0:
								abil_dict[key] = "put on your thinking cap"
							else:
								abil_dict[key] = "put on your dunce cap"
						_:
							if power > 0:
								abil_dict[key] = "buff its Brain"
							else:
								abil_dict[key] = "debuff its Brains"
				BuffKind.Guts:
					match effect_target_kind:
						TargetKind.Self:
							if power > 0:
								abil_dict[key] = "steel yourself"
							else:
								abil_dict[key] = "get nervous"
						_:
							if power > 0:
								abil_dict[key] = "buff its Guts"
							else:
								abil_dict[key] = "debuff its Guts"
				BuffKind.Eyesight:
					match effect_target_kind:
						TargetKind.Self:
							if power > 0:
								abil_dict[key] = "clear your vision"
							else:
								abil_dict[key] = "get something in your eye"
						_:
							if power > 0:
								abil_dict[key] = "buff its Eyesight"
							else:
								abil_dict[key] = "debuff its Eyesight"
				BuffKind.Footwork:
					match effect_target_kind:
						TargetKind.Self:
							if power > 0:
								abil_dict[key] = "bob and weave"
							else:
								abil_dict[key] = "trip over your own feet"
						_:
							if power > 0:
								abil_dict[key] = "buff its Footwork"
							else:
								abil_dict[key] = "debuff its Footwork"
				BuffKind.Hustle:
					match effect_target_kind:
						TargetKind.Self:
							if power > 0:
								abil_dict[key] = "put a little hustle on"
							else:
								abil_dict[key] = "become lethargic"
						_:
							if power > 0:
								abil_dict[key] = "buff its Hustle"
							else:
								abil_dict[key] = "debuff its Hustle"
		AbilityEffectKind.Damage:
			abil_dict[key] = "damage"
	key = "ability_target"
	if effect_kind != AbilityEffectKind.Buff: #buff abilities handled above
		match effect_target_kind:
			TargetKind.Allies:
				abil_dict[key] = "a buddy"
			TargetKind.Any:
				abil_dict[key] = "anything that moves"
			TargetKind.Enemies:
				abil_dict[key] = "a vile foe"
			TargetKind.Self:
				abil_dict[key] = "yourself"
	else:
		abil_dict[key] = ""
	key = "r"
	if ability_range > 0 and effect_target_kind != TargetKind.Self:
		abil_dict[key] = " in range {0} ".format([ability_range])
	else:
		abil_dict[key] = ""
	abil_dict["pow"] = power
	abil_dict["c"] = cooldown
	var description = "When {trigger_target} {trigger_effect}, {ability_effect} {ability_target}{r}by {pow}. Cooldown {c}.".format(abil_dict)
	return description
