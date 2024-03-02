extends Resource

class_name PriorityQueue

var _values: Array
var _priorities: Array

func insert(value, priority: int):
	var ix = _priorities.bsearch(priority, false)
	_values.insert(ix, value)
	_priorities.insert(ix, priority)

func pop_front():
	_priorities.pop_front()
	return _values.pop_front()
