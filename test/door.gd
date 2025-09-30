extends CharacterBody3D

@export var unlocked = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var open:bool = false
@export var mirror_for_opening:bool = false

func interact(_player:Player, _interact_area:Interactable):
	if _player.has_key(Global.Key_Type.GATE):
		var anim_string = "open_door_mirror"  if mirror_for_opening else "open_door"
		if open:
			animation_player.play_backwards(anim_string)
		else:
			animation_player.play(anim_string)
		var tween = create_tween()
		tween.tween_property(_player.blinders,"color",Color(0.0, 0.0, 0.0),2)
		tween.tween_callback(roll_credits)
	elif !unlocked: 
		Global.event_bus.emit(Global.BusType.PLAYER_NOTIFICATION, "Door requires gate key")
		return
		
func roll_credits():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://cutscenes/closing_cinematic.tscn")
