extends Resource

class_name PriorityQueue

var _values: Array
var _priorities: Array

func insert(value, priority: float):
	var ix = _priorities.bsearch(priority, false)
	_values.insert(ix, value)
	_priorities.insert(ix, priority)

func force_front(value, timestamp: float):
	_values.push_front(value)
	_priorities.push_front(timestamp)

func pop_front():
	_priorities.pop_front()
	return _values.pop_front()

func size():
	return _values.size()
