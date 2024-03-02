class_name DataUtil

const EncEvent = preload("res://data/encounter/EncEvent.gd")

static func dup_state(s: EncounterState) -> EncounterState:
	var new = deep_dup(s)
	assert(new is EncounterState)
	return new

static func deep_dup(what):
	var t = typeof(what)
	var it
	match t:
			TYPE_OBJECT:
				if what is Script:
					it = what
				else:
					it = dup_object(what)
			TYPE_DICTIONARY:
				it = dup_dict(what)
			TYPE_ARRAY:
				it = dup_array(what)
			TYPE_RAW_ARRAY:
				it = what.duplicate()
			TYPE_INT_ARRAY:
				it = what.duplicate()
			TYPE_REAL_ARRAY:
				it = what.duplicate()
			TYPE_STRING_ARRAY:
				it = what.duplicate()
			TYPE_VECTOR2_ARRAY:
				it = what.duplicate()
			TYPE_VECTOR3_ARRAY:
				it = what.duplicate()
			TYPE_COLOR_ARRAY:
				it = what.duplicate()
			_:  it = what
	return it

static func dup_object(o: Object) -> Object:
	var script = o.get_script()
	var new = script.new()
	var props = o.get_property_list()
	for prop_info in props:
		var prop_name = prop_info["name"]
		var prop_type = prop_info["type"]
		var what = o.get(prop_name)
		new.set(prop_name, deep_dup(what))
	return new

static func dup_array(a: Array) -> Array:
	var new = new_array()
	new.resize(a.size())
	for i in a.size():
		new[i] = deep_dup(a[i])
	return new

static func dup_dict(d: Dictionary) -> Dictionary:
	var new = {}
	for k in d.keys():
		new[k] = deep_dup(d[k])
	return new

static func update(state: EncounterState, event: EncounterEvent) -> EncounterEvent:
	match event.kind:
		EncounterEvent.EventKind.Move:
			state.set_location(event.actor_idx, event.target_location)
		EncounterEvent.EventKind.Attack:
			state.resolve_attack(event.actor_idx, event.target_idx, event.damage)
			var target = state.actors[event.target_idx]
			if !target.is_alive():
				return EncEvent.death_event(target)
		EncounterEvent.EventKind.Death:
			state.remove_actor(event.actor_idx)
	return null

static func new_array() -> Array:
	return []
