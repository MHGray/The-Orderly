extends Node3D

@onready var keycode_spawn: Marker3D = $KeycodeSpawn
@onready var audio_stream_player: AudioStreamPlayer3D = $AudioStreamPlayer
const WRITE_KEYCODE = preload("uid://cdv2uj2esvmnh")
const KEYCODE = preload("res://pickups/keycode.tscn")
const SLOW_TYPING = preload("uid://b72iyuf5b5r6")

func interact(_player:Player, _iactable:Interactable):
	if _player.has_tool(Global.Tool_Type.FLOPPY):
		var floppy = _player.holding_object
		_player.drop_held_object()
		floppy.model.queue_free()
		audio_stream_player.stream = WRITE_KEYCODE
		audio_stream_player.play()
		await audio_stream_player.finished
		var keycode:PickupModel = KEYCODE.instantiate()
		keycode_spawn.add_child(keycode)
	elif not audio_stream_player.playing:
		Global.notify_player("That orderly spends hours on this thing")
		audio_stream_player.stream = SLOW_TYPING
		audio_stream_player.play()
		
