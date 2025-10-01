extends Node3D

@export var enabled = true
@export var custom_interact_message:String
@export var thing_to_unlock:Door

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interactable: Interactable = $Interactable
@onready var key_1_marker: Marker3D = $lock/Key1Marker
@onready var key_2_marker: Marker3D = $lock/Key2Marker
@onready var key_3_marker: Marker3D = $lock/Key3Marker
@onready var audio_player_3d: AudioStreamPlayer3D = $AudioPlayer3D

const STONE_PLACE = preload("res://audio/sfx/stone_place.mp3")
var tween:Tween

var key_1:PickupModel
var key_2:PickupModel
var key_3:PickupModel
  
func interact(player:Player, _iactable:Interactable):
	if tween and tween.is_running(): return
	if player.has_key(Global.Key_Type.CHAPEL_1) and !key_1:
		var key:PickupModel = player.drop_held_object()
		key.freeze = true
		key.pickup.enabled = false
		tween = create_tween()
		tween.tween_property(key,"global_position", key_1_marker.global_position,0.5)
		tween.parallel()
		tween.tween_property(key,"global_rotation", key_1_marker.global_rotation,0.5)
		key_1 = key
		key.reparent(key_1_marker)
		tween.finished.connect(handle_tween_finished.bind(player),CONNECT_ONE_SHOT)
	elif player.has_key(Global.Key_Type.CHAPEL_2) and !key_2:
		var key:PickupModel = player.drop_held_object()
		key.freeze = true
		key.pickup.enabled = false
		tween = create_tween()
		tween.tween_property(key,"global_position", key_2_marker.global_position,0.5)
		tween.parallel()
		tween.tween_property(key,"global_rotation", key_2_marker.global_rotation,0.5)
		key_2 = key
		key.reparent(key_2_marker)
		tween.finished.connect(handle_tween_finished.bind(player),CONNECT_ONE_SHOT)
	elif player.has_key(Global.Key_Type.CHAPEL_3)and !key_3:
		var key:PickupModel = player.drop_held_object()
		key.freeze = true
		key.pickup.enabled = false
		tween = create_tween()
		tween.tween_property(key,"global_position", key_3_marker.global_position,0.5)
		tween.parallel()
		tween.tween_property(key,"global_rotation", key_3_marker.global_rotation,0.5)
		key_3 = key
		key.reparent(key_3_marker)
		tween.finished.connect(handle_tween_finished.bind(player),CONNECT_ONE_SHOT)
	else:
		Global.notify_player("What a strange thing to be on a wall.")
func handle_tween_finished(_player:Player):
	if !audio_player_3d.stream:
		audio_player_3d.stream = STONE_PLACE
	audio_player_3d.play()
	_player.player_made_noise(Player.PlayerNoise.create(global_position,Player.PlayerNoise.NoiseLevel.LOUD))
	if key_1 and key_2 and key_3:
		await get_tree().create_timer(1).timeout
		animation_player.play("explode")
		animation_player.animation_finished.connect(func(_unused):
			if !thing_to_unlock:
				push_error("forgot to set thing to unlock")
			thing_to_unlock.unlock()
			interactable.enabled = false
			queue_free()
		)
