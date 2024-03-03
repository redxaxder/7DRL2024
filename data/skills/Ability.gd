extends Resource

class_name Ability

enum TargetKind {Self, Enemies, Allies, Any}
enum TriggerEffectKind {Damage, Activated} # TODO add more
enum AbilityEffectKind {Damage} # TODO add more
var trigger_target_kind
var trigger_effect_kind
var effect_kind
var power: int = 0
var effect_target_kind
var message: String = ""
var aoe_radius: int = 0 # 0 means single target
var ability_range: int = 1 # 1 means melee

export var name: String

func initialize_ability(trigger_target, trigger_effect, ability_effect, apower, ability_target, amessage):
	trigger_target_kind = trigger_target
	trigger_effect_kind = trigger_effect
	effect_kind = ability_effect
	power = apower
	effect_target_kind = ability_target
	message = amessage
