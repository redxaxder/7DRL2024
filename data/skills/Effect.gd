extends Resource

class_name Effect
# An effect is something that happens to a space

# debuffs are just buffs with negative power

export var effect_type: int # damage or statbuff
export var targets: int = SkillsCore.Target.Enemies
export var mod_stat: int = -1 # if this is a buff/debuff, which stat is affected?
export var power: int # damage amount or buff amount or summon unit id
export var duration: int = 0
export var element: int = Elements.Kind.Physical
