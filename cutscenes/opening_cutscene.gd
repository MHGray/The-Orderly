extends Node3D

@onready var spot_light_3d: SpotLight3D = $SpotLight3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var light_target:Node3D

func _ready() -> void:
	animation_player.animation_finished.connect(handle_anim_finished)
	animation_player.play("ring ring")

func handle_anim_finished(anim_name:String):
	match(anim_name):
		"ring ring":
			animation_player.play("pick_up_phone")
		"pick_up_phone":
			animation_player.play("conversation")
		"conversation":
			animation_player.play("hang_up")
		"hang_up":
			animation_player.play("look_at_door")
		"look_at_door":
			animation_player.play("orderly_talking")
		"orderly_talking":
			get_tree().change_scene_to_file("res://cutscenes/opening_spiel.tscn")

func _process(_delta: float) -> void:
	if light_target:
		spot_light_3d.look_at(light_target.global_position)

func light_track_target(target_group:String):
	light_target = get_tree().get_first_node_in_group(target_group)
	print(light_target)
	
func light_stop_tracking():
	light_target = null


func _on_button_pressed() -> void:
	var loading_screen:LoadingScreen = LoadingScreen.create()
	loading_screen.scene_to_load = "res://test/test_3d.tscn"
	get_tree().root.add_child(loading_screen)
	var old_scene = get_tree().current_scene
	get_tree().current_scene = loading_screen
	old_scene.queue_free()
