extends Control

var actor: CombatEntity setget set_actor
func set_actor(x):
	actor = x
	_refresh()

func _ready():
	self_modulate = Constants.CLEAR_COLOR

func _refresh():
	if !actor:
		visible = false
		return
	visible = true
	get_node("%actorname").text = Actor.get_name(actor.actor_type)
	get_node("%hpval").text = "{0} / {1}".format([actor.cur_hp, actor.stats.max_hp()])
	get_node("%speedval").text = "{0}".format([actor.stats.speed()])
	get_node("%accuracyval").text = "{0}".format([actor.stats.accuracy()])
	get_node("%evasionval").text = "{0}".format([actor.stats.evasion()])
	get_node("%damageval").text = "{0}".format([actor.stats.damage()])
	get_node("%critval").text = "{0}".format([actor.stats.crit()])
