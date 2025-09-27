extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interactable: Interactable = $HidingSpot
@onready var hiding_camera: Camera3D = $"Hiding Camera"
@onready var hiding_camera_target: Marker3D = $"Hiding Camera Target"

var player_state_before_hide:Player.State
var _player:Player
var init_pos:Vector3
var player_inside:bool = false

func interact(player:Player,_iactable:Interactable):
	if !_player: 
		_player = player
	if player_inside and !animation_player.is_playing():
		animation_player.play("unhide")
		if !animation_player.animation_finished.is_connected(finish_hiding):
			animation_player.connect("animation_finished",finish_hiding.bind(player),CONNECT_ONE_SHOT)
	elif !animation_player.is_playing():
		player_state_before_hide = player.state
		hiding_camera.global_position = _player.camera_3d.global_position
		hiding_camera.global_rotation = _player.camera_3d.global_rotation
		player.start_hiding(hiding_camera, interact.bind(player,interactable))
		animation_player.play("hide")
		interactable.custom_interact_message = "Press [E] or [SPACE] to leave"
		player_inside = true
		
func finish_hiding(_anim_name,player:Player):
	player_inside = false
	player.stop_hiding(player_state_before_hide)
	interactable.custom_interact_message = "Press [E] or [Space] to hide"
	player.camera_3d.global_rotation = hiding_camera.global_rotation

func move_camera_toward_target():
	if !_player: return
	var tween = create_tween()
	init_pos = _player.camera_3d.global_position
	tween.tween_method(put_camera_on_target_path, 0.0, 1.0, 1)
	await tween.finished
	hiding_camera.reparent(hiding_camera_target,true)

func put_camera_on_target_path(progress):
	hiding_camera.global_position = init_pos.lerp(hiding_camera_target.global_position, progress)

func pull_camera_from_target_path(progress):
	init_pos = hiding_camera_target.global_position
	hiding_camera.global_position = init_pos.lerp(_player.camera_3d.global_position, progress)

func move_camera_toward_player_eyeballs():
	if !_player: return
	hiding_camera.reparent(self)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(pull_camera_from_target_path,0.0,1.0,.5)
	await tween.finished
