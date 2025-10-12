extends Control

const SETTINGS = preload("res://menus/settings.tscn")
const CREDITS = preload("res://credits.tscn")

var player:Player
@onready var menu: VBoxContainer = $Menu
@onready var texture_rect: TextureRect = $TextureRect
@onready var film_grain: TextureRect = $FilmGrain

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
	
func _on_settings_btn_pressed() -> void:
	$Menu2.visible = false
	var settings_menu:Control = SETTINGS.instantiate()
	menu.visible = false
	texture_rect.visible = false
	film_grain.visible = false
	settings_menu.closing.connect(func():
		$Menu2.visible = true
		menu.visible = true
		texture_rect.visible = true
		film_grain.visible = true
	)
	add_child(settings_menu)
	
