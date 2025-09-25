extends Node3D

class_name Dumbwaiter

@export var open:bool
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var player:Player
@export var floor:Floor
@onready var player_arrival_point: Marker3D = $Player_Arrival_Point

enum Floor{NULL, TOP, BOTTOM}

func interact(_player:Player, _iactable:Interactable):
	if animation_player.is_playing(): return
	if !player:
		player = _player
	if !open:
		animation_player.play("open")
		open = true
		await get_tree().create_timer(30).timeout
		animation_player.play_backwards("open")
		open = false
	else:
		animation_player.play("ride")

func fade_to_black(time:float = 1.0):
	player.blinders.color = Color(0.009, 0.01, 0.01,0.0)
	var tween:Tween = create_tween()
	tween.tween_property(player.blinders, "color", Color(0.009, 0.01, 0.01, 1.0), time)

func regain_peepers(time:float = 1.0):
	player.blinders.color =  Color(0.009, 0.01, 0.01, 1.0)
	var tween:Tween = create_tween()
	tween.tween_property(player.blinders, "color",Color(0.009, 0.01, 0.01,0.0), time)

func teleport_player():
	var target:Dumbwaiter
	if floor == Floor.TOP:
		var dumbwaiters = get_tree().get_nodes_in_group("dumbwaiter")
		target = dumbwaiters.filter(func(x:Dumbwaiter):
			return x.floor == Floor.BOTTOM
			)[0]
	if floor == Floor.BOTTOM:
		var dumbwaiters = get_tree().get_nodes_in_group("dumbwaiter")
		target = dumbwaiters.filter(func(x:Dumbwaiter):
			return x.floor == Floor.TOP
			)[0]
	player.global_position = target.player_arrival_point.global_position
	player.camera_3d.make_current()
