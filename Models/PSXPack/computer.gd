extends Node3D

@onready var keycode_spawn: Marker3D = $KeycodeSpawn
@onready var audio_stream_player: AudioStreamPlayer3D = $AudioStreamPlayer

const KEYCODE = preload("res://pickups/keycode.tscn")

func interact(_player:Player, _iactable:Interactable):
	if _player.has_tool(Global.Tool_Type.FLOPPY):
		var floppy = _player.holding_object
		_player.drop_held_object()
		floppy.model.queue_free()
		audio_stream_player.play()
		await audio_stream_player.finished
		var keycode:PickupModel = KEYCODE.instantiate()
		keycode_spawn.add_child(keycode)
