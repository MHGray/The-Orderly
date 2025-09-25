extends Node3D

@onready var interactable: Interactable = $Interactable
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hiding_camera: Camera3D = $HidingCamera
@onready var right_side: Marker3D = $RightSide
@onready var left_side: Marker3D = $LeftSide
@export var left_side_disabled:bool
@export var right_side_disabled:bool

var player_state_before_hide:Player.State

var player_inside:bool = false

func interact(player:Player,_iactable:Interactable):
	var anim:String
	if player.global_position.distance_squared_to(left_side.global_position) < player.global_position.distance_squared_to(right_side.global_position):
		if left_side_disabled: return
		anim = "hide_left"
	else:
		if right_side_disabled: return
		anim = "hide_right"
	if player_inside:
		animation_player.play_backwards(anim)
		if !animation_player.animation_finished.is_connected(finish_hiding):
			animation_player.connect("animation_finished",finish_hiding.bind(player),CONNECT_ONE_SHOT)
	else:
		player_state_before_hide = player.state
		player.start_hiding(hiding_camera, interact.bind(player,interactable))
		animation_player.play(anim)
		interactable.custom_interact_message = "Press [E] or [SPACE] to leave"
		player_inside = true
		
func finish_hiding(_anim_name,player:Player):
	player_inside = false
	player.stop_hiding(player_state_before_hide)
	interactable.custom_interact_message = "Press [E] or [Space] to hide"
	player.camera_3d.global_rotation = hiding_camera.global_rotation
