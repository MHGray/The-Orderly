extends Pickup

@onready var vase_001: RigidBody3D = $"../Vase/Vase_001"
@onready var vase_002: RigidBody3D = $"../Vase/Vase_002"
@onready var vase: RigidBody3D = $"../Vase"
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $"../AudioStreamPlayer3D"

func pickup(_player:Player):
	picked_up.emit()
	model.disable()
	
	dropped.connect(explode.bind(_player), CONNECT_ONE_SHOT)
	
	if custom_pickup:
		return custom_pickup.pickup()
	if alternate_return_on_pickup:
		return alternate_return_on_pickup
	return self

func explode(player:Player):
	audio_stream_player_3d.play()
	vase.freeze = false
	vase.linear_velocity = Vector3(randf_range(-7,7),randf_range(-7,7),randf_range(-7,7))
	vase_001.freeze = false
	vase_001.linear_velocity = Vector3(randf_range(-7,7),randf_range(-7,7),randf_range(-7,7))
	vase_002.freeze = false
	vase_002.linear_velocity = Vector3(randf_range(-7,7),randf_range(-7,7),randf_range(-7,7))
	enabled = false
	Global.vase_smashed()
	player.player_made_noise(Player.PlayerNoise.create(player.global_position,Player.PlayerNoise.NoiseLevel.LOUD))
	await get_tree().create_timer(30).timeout
	model.queue_free()
