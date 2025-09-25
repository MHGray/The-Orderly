extends Node

@export var thing_to_unlock:Node3D
@export var required_key:Global.Key_Type
@export var required_tool:Global.Tool_Type
@export var animation_player:AnimationPlayer
@export var interactable: Interactable
@export var not_holding_key_message: String
@export var destroy_after_use:bool = true
var locked = true

func interact(player:Player, _interact_area:Interactable):
	if required_key != 0 and player.has_key(required_key):
		unlock()
	elif required_tool != 0 and player.has_tool(required_tool):
		unlock()
	else:
		Global.notify_player(not_holding_key_message)

func unlock():
	if !locked: return
	interactable.enabled = false
	locked = false
	if animation_player and animation_player.has_animation("unlock"):
		animation_player.play("unlock")
		animation_player.animation_finished.connect(func(_unused = null):
			thing_to_unlock.unlock()
			if destroy_after_use:
				get_tree().create_timer(30).timeout.connect(queue_free)
		, CONNECT_ONE_SHOT)
	else:
		thing_to_unlock.unlock()
		if destroy_after_use:
			get_tree().create_timer(30).timeout.connect(queue_free)
	
