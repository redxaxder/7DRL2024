extends Resource

class_name EncounterEvent

export var delta: int = 0

enum EventKind {Attack, Move}
var kind

var actor_idx: int
var target_idx: int
var damage: int
var did_hit: bool

var target_location: Vector2
