class_name EncounterEventKind

enum Kind { Attack, Move, Death, AbilityActivation, Damage, PrepareReaction, StatChange, Miss, Bloodied, EncounterStart, Spawn }

# Is this event's log message visible by default?
# this is overriden by show_extra_history=true
static func is_displayed(kind: int) -> bool:
	match kind:
		Kind.Move: return false
		Kind.Bloodied: return false
		Kind.PrepareReaction: return false
#		Kind.StatChange: return false
		_: return true

# When the sim is in playback mode, does it play this event 
# normally or does it skip past it?
static func is_animated(kind: int) -> bool:
	match kind:
		Kind.Move: return true
		Kind.Attack: return true
		Kind.Damage: return true
#		Kind.StatChange: return true
		Kind.AbilityActivation: return true
		_: return false

