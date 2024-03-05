extends Resource

class_name Effect
# An effect is something that happens to a space

# debuffs are just buffs with negative power

var effect_type: int # damage or statbuff
var targets: int = SkillsCore.Target.Enemies
var mod_stat: int = -1 # if this is a buff/debuff, which stat is affected?
var power: int # damage amount or buff amount
var duration: int = 0
var element: int = Elements.Kind.Physical
