class_name SkillsCore

enum EffectType { Damage, StatBuff, Summon } #TBD: other kinds of buffs; summons
# accelerate turn priority (via "bonus time")

enum Trigger { 
	Action, # the actor initiates the skill using their turn
	Automatic, # automatic listens for events
	}


enum TriggerAim { 
	Self, # trigger aims at the owner of the ability
	EventSource, # trigger aims at the originator of the event that tripped it
	EventTarget, # trigger aims at the target of the event that tripped it
	Random, # trigger aims at some appropriate target
	}

# where can the effect take place?
# this is used in two kinds of checks:
# 1) to determine if an effect affects a space
# 2) to filter what events triggers listen to
enum Target {Self = 1, Enemies = 2, Allies = 4, Empty = 8}
const TargetAny = Target.Self | Target.Enemies | Target.Allies

