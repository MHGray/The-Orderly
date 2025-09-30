extends Control

const SETTINGS = preload("res://menus/settings.tscn")
@onready var texture_rect: TextureRect = $TextureRect
@onready var menu: VBoxContainer = $Menu
@onready var film_grain: TextureRect = $FilmGrain
@onready var animation_player: AnimationPlayer = $AnimationPlayer
const CREDITS = preload("res://credits.tscn")
const OPENING_CUTSCENE = preload("uid://b4f45hcrjw18d")
@onready var the_orderly_mixamod_test: CharacterBody3D = $TheOrderlyMixamodTest
@onready var omni_light_3d: OmniLight3D = $OmniLight3D

func _ready() -> void:
	if Global.beat_the_game:
		the_orderly_mixamod_test.visible = true
		omni_light_3d.visible = true
	Maestro.play_music("mainmenu")

func _on_start_btn_pressed() -> void:
	Maestro.stop_music()
	animation_player.play("start_game")
	animation_player.animation_finished.connect(func(_unused):
		get_tree().change_scene_to_packed(OPENING_CUTSCENE)
	, CONNECT_ONE_SHOT)

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

func _on_credits_btn_pressed() -> void:
	var credits_menu:Control = CREDITS.instantiate()
	menu.visible = false
	texture_rect.visible = false
	film_grain.visible = false
	credits_menu.closing.connect(func():
		menu.visible = true
		texture_rect.visible = true
		film_grain.visible = true
	)
	add_child(credits_menu)


func _on_other_btn_pressed() -> void:
	if OS.get_name() == "HTML5":
		var message = $WebExitMessage
		message.visible = true
		await get_tree().create_timer(5).timeout
		message.visible = false
	else:
		get_tree().quit()
