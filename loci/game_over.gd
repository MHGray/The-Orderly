extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.animation_finished.connect(func(_unused:String):
		get_tree().change_scene_to_file("res://loci/main_menu_locus.tscn")
	)
