extends Resource

class_name EncounterState

export var i: int = 0

var player: CombatEntity
var actors: Array # [CombatEntity]
var map: Dictionary # [location Vector2, index in the actor array]
					# represent walls etc with -1?
