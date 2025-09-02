extends CharacterBody3D

@export var unlocked = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var open:bool = false
@export var mirror_for_opening:bool = false

func interact(_player:Player):
	if !unlocked: 
		Global.event_bus.emit(Global.Bus_Type.PLAYER_NOTIFICATION, "Door requires gate key")
		return
		
	var anim_string = "open_door_mirror"  if mirror_for_opening else "open_door"
	if open:
		animation_player.play_backwards(anim_string)
	else:
		animation_player.play(anim_string)
	open = !open
		
