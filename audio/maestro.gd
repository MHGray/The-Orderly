extends Node

@export var musics: Dictionary[String,AudioStreamMP3]

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer
@onready var voice_player: AudioStreamPlayer = $VoicePlayer

enum BUS_TYPE{
	NULL,SFX,MUSIC,VOICE
}

func _ready() -> void:
	if OS.is_debug_build():
		music_player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
	else:
		music_player.playback_type = AudioServer.PLAYBACK_TYPE_SAMPLE

func play_music(music_name:String, loop:bool = true) -> AudioStreamPlayer:
	if !musics.has(music_name):
		printerr("Tried playing music that didn't exist: ", music_name)
		return null
	music_player.stream = musics[music_name]
	music_player.stream.loop = loop
	music_player.play()
	return music_player

func stop_music():
	music_player.stop()
