extends Resource

class_name Activation

# what kind of event triggers this?
export var trigger = SkillsCore.Trigger.Action
# for automatic triggers: where does the effect get applied
export var trigger_aim = SkillsCore.TriggerAim.EventSource

# how many spaces around the targeted one get hit
# the effect is applied to all appropriate targets within the radius
export var radius: int = 0

export var ability_range: int = 1 # 1 means melee

# cooldown is hooked up to the time system, not to turns taken or events
# eg. increasing a unit's speed doesn't make its cooldowns go by faster,
# and hitting it more doesn't either
export var cooldown_time: int = 30 
export var filter: int = 0 # what kinds of things activate this skill?
export var filter_actor = SkillsCore.TargetAny # me, ally, enemy, any

enum Filter{
	DamageDealt, 
	DamageReceived,
	Death,
	Movement,
	Start,
	Bloodied,
	Miss,
	Dodge,
	Attack,
	#cheap to add
	# uses ability
	# misses
	# encounter start
	# fixed threshold (25%) "bloodied"
	# attack
	# medium
	# on-crit
	#medium
	# overkill
	MAX
	}
enum FilterFocus { Source, Target }
const FILTER_FOCUS = [
	FilterFocus.Source, # DamageDealt "who dealt the damage"
	FilterFocus.Target, # DamageRecieved "who got hurt"
	FilterFocus.Target, # Death "who died" 
	FilterFocus.Source, # Movement "who moved"
	FilterFocus.Source, # Start " always player "
	FilterFocus.Target, # Bloodied " who gets bloodied"
	FilterFocus.Source, # Miss   " who misses"
	FilterFocus.Target, # Dodge   " who is missed"
	FilterFocus.Source, # Attack " who attacks"
	]
const FILTER_EVENT = [
	EncounterEventKind.Kind.Damage, # DamageDealt
	EncounterEventKind.Kind.Damage, # DamageReceived
	EncounterEventKind.Kind.Death, # Death
	EncounterEventKind.Kind.Move,  # Movement
	EncounterEventKind.Kind.EncounterStart,  # Start
	EncounterEventKind.Kind.Bloodied,  # Bloodied
	EncounterEventKind.Kind.Miss,     # Miss
	EncounterEventKind.Kind.Miss,     # Dodge
	EncounterEventKind.Kind.Attack,  # Attack
	]

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
	return SkillsCore.NoTargetFilter
func filter_event_target():
	if FILTER_FOCUS[filter] == FilterFocus.Target:
		return filter_actor
	return SkillsCore.NoTargetFilter


