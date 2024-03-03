class_name Constants

const MAP_BOUNDARIES: Rect2 = Rect2(0,0,10,10)
const TILE_MARGIN: int = 1
const TILE_SIZE: int = 8


const PLAYER_FACTION: int = 1
const ENEMY_FACTION: int = 2

const ANY_FACTION: int = PLAYER_FACTION | ENEMY_FACTION

static func negate_faction(faction: int) -> int:
	return ANY_FACTION ^ faction

static func matches_mask(faction: int, faction_mask: int) -> bool:
	return faction & faction_mask > 0
