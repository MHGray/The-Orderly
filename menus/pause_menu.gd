extends Control

var player:Player

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		player.resume.call_deferred()
		Engine.time_scale = 1
		queue_free()

func _on_resume_btn_pressed() -> void:
	player.resume.call_deferred()
	Engine.time_scale = 1
	queue_free()

func _on_return_to_main_btn_pressed() -> void:
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://loci/main_menu_locus.tscn")


func _on_credits_btn_pressed() -> void:
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://credits.tscn")
	
