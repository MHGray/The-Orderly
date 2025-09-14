extends Control

const SETTINGS = preload("res://menus/settings.tscn")
@onready var texture_rect: TextureRect = $TextureRect
@onready var menu: VBoxContainer = $Menu
@onready var film_grain: TextureRect = $FilmGrain

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


func _on_settings_btn_pressed() -> void:
	var settings_menu:Control = SETTINGS.instantiate()
	menu.visible = false
	texture_rect.visible = false
	film_grain.visible = false
	settings_menu.closing.connect(func():
		menu.visible = true
		texture_rect.visible = true
		film_grain.visible = true
		Maestro.music_player.play(Maestro.music_player.get_playback_position())
	)
	add_child(settings_menu)
