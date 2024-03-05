extends Resource

class_name Activation

# what kind of event triggers this?
var trigger = SkillsCore.Trigger.Action

# for automatic triggers: which events will trigger this?
var filter_event_type = -1
var filter_event_source = SkillsCore.TargetAny
var filter_event_target = SkillsCore.TargetAny

# for automatic triggers: where does the effect get applied
var trigger_aim = SkillsCore.TriggerAim.EventSource

# how many spaces around the targeted one get hit
# the effect is applied to all appropriate targets within the radius
var radius: int = 0

var ability_range: int = 1 # 1 means melee

# cooldown is hooked up to the time system, not to turns taken or events
# eg. increasing a unit's speed doesn't make its cooldowns go by faster,
# and hitting it more doesn't either
var cooldown_time: int = 30 
