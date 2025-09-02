extends Node3D

@export var required_key:Global.Key_Type
@export var animation_player:AnimationPlayer
@export var interactable: Interactable

var locked = true

func interact(player:Player):
	if player.has_key(required_key):
		unlock()
	else:
		pass

func unlock():
	interactable.enabled = false
	locked = false
	if animation_player.has_animation("unlock"):
		animation_player.play("unlock")
	
