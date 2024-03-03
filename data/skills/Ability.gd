extends Resource

class_name Ability

enum TargetKind {Self, Enemies, Allies, Any}
enum TriggerEffectKind {Damage, Activated} # TODO add more
enum AbilityEffectKind {Damage, Buff} # TODO add more
enum BuffKind {Brawn, Brains, Guts, Eyesight, Footwork, Hustle}
var trigger_target_kind
var trigger_effect_kind
var effect_kind
var power: int = 0
var effect_target_kind
var message: String = ""
var aoe_radius: int = 0 # 0 means single target
var ability_range: int = 1 # 1 means melee
var buff_kind
var cooldown: int = 0
var cooldown_max: int = 1

export var name: String

func initialize_ability(trigger_target, trigger_effect, ability_effect, apower: int, ability_target, amessage: String, acooldown: int):
	trigger_target_kind = trigger_target
	trigger_effect_kind = trigger_effect
	effect_kind = ability_effect
	power = apower
	effect_target_kind = ability_target
	message = amessage
	cooldown_max = acooldown

func on_cooldown() -> bool:
	return cooldown > 0
	
func cool():
	assert(cooldown > 0)
	cooldown -= 1

func use():
	assert(cooldown == 0)
	cooldown = cooldown_max
