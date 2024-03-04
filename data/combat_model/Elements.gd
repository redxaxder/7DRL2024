extends Resource

class_name Elements

enum Kind {Physical, Fire, Ice, Poison}

# if present, attack has this elementx
var attack_modifiers: Dictionary # <Kind, bool>

# if resistance, 0 < float < 1
# if weakness float > 1
var defense_modifiers: Dictionary # <Kind, float>
