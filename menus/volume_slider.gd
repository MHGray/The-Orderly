extends HSlider

@export var bus_name:String
@export var sample_to_play:String
@export var type_of_sample:Maestro.BUS_TYPE

@onready var music_bus = AudioServer.get_bus_index(bus_name)

func _ready() -> void:
	value = AudioServer.get_bus_volume_db(music_bus)

func _on_value_changed(val):
	AudioServer.set_bus_volume_linear(music_bus, val)
	
	if(val == 0):
		AudioServer.set_bus_mute(music_bus,true)
	else:
		AudioServer.set_bus_mute(music_bus,false)
		
	match type_of_sample:
		Maestro.BUS_TYPE.MUSIC:
			if !Maestro.music_player.playing:
				Maestro.play_music(sample_to_play,false)
		Maestro.BUS_TYPE.SFX:
			pass
		Maestro.BUS_TYPE.VOICE:
			pass
