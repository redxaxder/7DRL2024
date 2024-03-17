class_name Constants

const MAP_BOUNDARIES: Rect2 = Rect2(0,0,13,13)
const TILE_MARGIN: int = 1
const TILE_SIZE: int = 8
const TILE_ENVELOPE = TILE_SIZE + TILE_MARGIN

const PLAYER_FACTION: int = 1
const ENEMY_FACTION: int = 2

const ANY_FACTION: int = PLAYER_FACTION | ENEMY_FACTION

static func negate_faction(faction: int) -> int:
	return ANY_FACTION ^ faction

static func matches_mask(mask_1: int, mask2: int) -> bool:
	return mask_1 & mask2 > 0


const CLEAR_COLOR: Color = Color(0.086275, 0.082353, 0.098039)

const debug_mode = true
