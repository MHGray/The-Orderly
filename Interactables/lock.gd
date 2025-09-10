extends Node

@export var required_key:Global.Key_Type
@export var animation_player:AnimationPlayer
@export var interactable: Interactable

var locked = true

signal unlocked

func interact(player:Player, _interact_area:Interactable):
	if player.has_key(required_key):
		unlock()
	else:
		var key_string:String = Global.Key_Type.find_key(required_key)
		key_string = key_string.capitalize() + " Key"
		Global.notify_player("Requires %s" % key_string)

func unlock():
	interactable.enabled = false
	locked = false
	if animation_player.has_animation("unlock"):
		animation_player.play("unlock")
		animation_player.animation_finished.connect(func(_unused = null):
			unlocked.emit()
			die(), CONNECT_ONE_SHOT)

func die():
	get_parent().queue_free()
