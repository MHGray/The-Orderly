extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hiding_camera: Camera3D = $"Hiding Camera"
@onready var interactable: Interactable = $HidingSpot

var player_state_before_hide:Player.State

var player_inside:bool = false

func interact(player:Player,_iactable:Interactable):
	if player_inside:
		animation_player.play("unhide")
		if !animation_player.animation_finished.is_connected(finish_hiding):
			animation_player.connect("animation_finished",finish_hiding.bind(player),CONNECT_ONE_SHOT)
	else:
		player_state_before_hide = player.state
		player.start_hiding(hiding_camera, interact.bind(player,interactable))
		animation_player.play("hide")
		interactable.custom_interact_message = "Press [E] or [SPACE] to leave"
		player_inside = true
		
func finish_hiding(_anim_name,player:Player):
	player_inside = false
	player.stop_hiding(player_state_before_hide)
	interactable.custom_interact_message = "Press [E] or [Space] to hide"
	player.camera_3d.global_rotation = hiding_camera.global_rotation
