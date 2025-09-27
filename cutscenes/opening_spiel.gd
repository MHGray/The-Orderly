extends Control

func change_scene():
	var loading_screen:LoadingScreen = LoadingScreen.create()
	loading_screen.scene_to_load = "res://test/test_3d.tscn"
	get_tree().root.add_child(loading_screen)
	var old_scene = get_tree().current_scene
	get_tree().current_scene = loading_screen
	old_scene.queue_free()
