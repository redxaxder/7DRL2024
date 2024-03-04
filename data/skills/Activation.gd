extends Resource

class_name Activation

# what specifically triggers this?
var trigger_effect = SkillsCore.Trigger.Action
# for automatic triggers: events involving which actors are listened for?
var trigger_listen = SkillsCore.Target.Self
# for automatic triggers: where does the effect get applied
var trigger_aim = SkillsCore.TriggerAim.Random

# how many spaces around the targeted one get hit
# the effect is applied to all appropriate targets within the radius
var radius: int = 0

var ability_range: int = 1 # 1 means melee

# cooldown is hooked up to the time system, not to turns taken or events
# eg. increasing a unit's speed doesn't make its cooldowns go by faster,
# and hitting it more doesn't either
var cooldown_time: int = 30 
