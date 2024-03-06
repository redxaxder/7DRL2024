extends Resource

class_name Activation

# what kind of event triggers this?
var trigger = SkillsCore.Trigger.Action
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

enum Filter{
	DamageDealt, 
	DamageRecieved,
	Death,
	#cheap to add
	# movement
	# uses ability
	# misses
	# encounter start
	# fixed threshold (25%) "bloodied"
	# attack
	# medium
	# on-crit
	#medium
	# overkill
	}
enum FilterFocus { Source, Target }
const FILTER_FOCUS = [
	FilterFocus.Source, # DamageDealt
	FilterFocus.Target, # DamageRecieved
	FilterFocus.Target, # Death
	]
const FILTER_EVENT = [
	EncounterEventKind.Kind.Damage, # DamageDealt
	EncounterEventKind.Kind.Damage, # DamageRecieved
	EncounterEventKind.Kind.Death, # Death
	]
var filter: int = 0
var filter_actor = SkillsCore.TargetAny # me, ally, enemy, any

# desired statuses
#  stat increase/decrease, but temporaty
#  shield
#  DOT
#  

func filter_event_type():
	return FILTER_EVENT[filter]
func filter_event_source():
	if FILTER_FOCUS[filter] == FilterFocus.Source:
		return filter_actor
	return SkillsCore.TargetAny
func filter_event_target():
	if FILTER_FOCUS[filter] == FilterFocus.Target:
		return filter_actor
	return SkillsCore.TargetAny


