extends RigidBody3D

@onready var collision_shape_3d_2: CollisionShape3D = $CollisionShape3D2
@onready var teapot: MeshInstance3D = $Teapot
@onready var growplayer: AudioStreamPlayer3D = $growplayer
@onready var shrinkplayer: AudioStreamPlayer3D = $shrinkplayer

@export var click_size = 1.5 * Vector3.ONE
@export var click_size_division:Vector3
@export var click_time = 1.5
var being_clicked:bool = false

func _process(delta):
	if being_clicked: return
	if randi_range(0,10000) < 0:
		_on_click() 

func _on_click():
	being_clicked = true
	var tween:Tween = create_tween()
	tween.set("scale", click_size)
	tween.set_trans(Tween.TransitionType.TRANS_CUBIC)
	tween.tween_property(collision_shape_3d_2, "scale", click_size,click_time)
	tween.set_parallel()
	growplayer.pitch_scale = randf_range(.85,1.15)
	growplayer.play()
	tween.tween_property(teapot, "scale", click_size,click_time)
	
	get_tree().create_timer(click_time*5).timeout.connect(func():
		var tween2:Tween = create_tween()
		tween2.set("scale", click_size)
		shrinkplayer.pitch_scale = randf_range(.85,1.15)
		shrinkplayer.play()
		
		tween.set_trans(Tween.TransitionType.TRANS_CUBIC)
		tween2.tween_property(collision_shape_3d_2, "scale", click_size_division,click_time/2.0)
		tween2.set_parallel()
		tween2.tween_property(teapot, "scale", click_size_division,click_time/2.0)
		set_physics_process(true)
		being_clicked = false
		
	)
	pass


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		_on_click()
