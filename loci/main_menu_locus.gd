extends Control

func _ready() -> void:
	Maestro.play_music("mainmenu")
	print("Should be playing main menu")

func _on_start_btn_pressed() -> void:
	Maestro.stop_music()
	var loading_screen:LoadingScreen = LoadingScreen.create()
	loading_screen.scene_to_load = "res://test/test_3d.tscn"
	get_tree().root.add_child(loading_screen)
	var old_scene = get_tree().current_scene
	get_tree().current_scene = loading_screen
	old_scene.queue_free()
