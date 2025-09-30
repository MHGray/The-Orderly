extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
const MAIN_MENU_LOCUS = preload("uid://cswtphud07syg")

func _ready() -> void:
	var orig_volume:float = Maestro.get_current_music_volume_db()
	Maestro.set_music_volume_db(-80.0)
	Maestro.play_music("mainmenu")
	Maestro.music_player.seek(40)
	Maestro.fade_music(-80, orig_volume, 2.5)
	animation_player.play("closing_spiel")
	animation_player.connect("animation_finished", func(_unused):
		Maestro.fade_music(Maestro.get_current_music_volume_db(),-80, 2)
		animation_player.play("closing_sequence")
		animation_player.animation_finished.connect(change_scene.bind(orig_volume))
	,CONNECT_ONE_SHOT)
func change_scene(_unused, volume:float):
	Maestro.set_music_volume_db(volume)
	Global.beat_the_game = true
	get_tree().change_scene_to_file("res://loci/main_menu_locus.tscn")
