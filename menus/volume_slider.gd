extends HSlider

@export var bus_name:String
@export var sample_to_play:String
@export var type_of_sample:Maestro.BUS_TYPE

var bus_index:int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	value = AudioServer.get_bus_volume_linear(bus_index)
	Maestro.stop_music()

func _on_value_changed(val):
	AudioServer.set_bus_volume_linear(bus_index, val)
	
	if bus_name != "MUSIC":
		Maestro.stop_music()
		
	
	if(val == 0):
		AudioServer.set_bus_mute(bus_index,true)
	else:
		AudioServer.set_bus_mute(bus_index,false)
		
	match type_of_sample:
		Maestro.BUS_TYPE.MUSIC:
			if !Maestro.music_player.playing:
				Maestro.music_player.play()
		Maestro.BUS_TYPE.SFX:
			var index:int = AudioServer.get_bus_index("RaytracedReverb")
			AudioServer.set_bus_volume_linear(index, val)
			index = AudioServer.get_bus_index("RaytracedAmbient")
			AudioServer.set_bus_volume_linear(index, val)
			if !Maestro.sfx_player.playing:
				Maestro.sfx_player.play()
		Maestro.BUS_TYPE.VOICE:
			if !Maestro.sfx_player.playing:
				Maestro.sfx_player.play()
