extends AudioStreamPlayer3D

func _ready() -> void:
	playback_type = AudioServer.PLAYBACK_TYPE_SAMPLE
	if OS.get_name() != "Web":
		playback_type = AudioServer.PLAYBACK_TYPE_STREAM

func randomize_pitch(min:float = .92, _max:float = 1.07):
	pitch_scale = randf_range(min,_max)
