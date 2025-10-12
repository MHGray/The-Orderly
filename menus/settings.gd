extends Control

class_name SettingsMenu

@onready var music_slider: HSlider = $AudioSettings/MusicSlider
@onready var sound_slider: HSlider = $AudioSettings/SoundSlider
@onready var voice_slider: HSlider = $AudioSettings/VoiceSlider
@onready var mouse_sensitivity: HSlider = $OtherSettings/MouseSensitivity

signal closing

func _ready() -> void:
	mouse_sensitivity.value = Global.mouse_sensitivity * 1000
	if OS.get_name() == "Web":
		$OtherSettings/Button.visible = false
func _on_exit_btn_pressed() -> void:
	closing.emit()
	queue_free()

func _on_mouse_sensitivity_value_changed(value: float) -> void:
	Global.mouse_sensitivity = value * .001


func _on_button_pressed() -> void:
	Global.fullscreen = !Global.fullscreen
	print(Global.fullscreen)
	if Global.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) 
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED) 
		
