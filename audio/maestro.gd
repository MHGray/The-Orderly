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

func get_current_music_volume_db() -> float:
	var bus_index = AudioServer.get_bus_index("MUSIC")
	return AudioServer.get_bus_volume_db(bus_index)

func set_music_volume_db(amount:float) -> void:
	var bus_index = AudioServer.get_bus_index("MUSIC")
	AudioServer.set_bus_volume_db(bus_index, amount)

func fade_music(start_volume_db:float, end_volume_db:float, delta:float ):
	var bus_index = AudioServer.get_bus_index("MUSIC")
	AudioServer.set_bus_volume_db(bus_index, start_volume_db)
	var tween:Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(func(progress):
		AudioServer.set_bus_volume_db(bus_index, lerpf(start_volume_db, end_volume_db, progress) )
		,0.0,1.0,delta)

func stop_music():
	music_player.stop()
