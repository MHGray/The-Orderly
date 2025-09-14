extends Control

class_name SettingsMenu

@onready var music_slider: HSlider = $AudioSettings/MusicSlider
@onready var sound_slider: HSlider = $AudioSettings/SoundSlider
@onready var voice_slider: HSlider = $AudioSettings/VoiceSlider

signal closing

func _on_exit_btn_pressed() -> void:
	closing.emit()
	queue_free()
