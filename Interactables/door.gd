@tool
extends Node3D

class_name Door

const DOOR_LOCKED = preload("res://audio/sfx/door_locked.mp3")

@onready var plane: MeshInstance3D = $Plane
@onready var locked_collision: CollisionShape3D = $LockedBody/LockedCollision
var playing:bool


@export var interactables:Dictionary[String,Interactable]:
	set(value):
		interactables = value
		set_interactables(enabled)
@export var baking_door:bool:
	set(value):
		baking_door = value
		if plane:
			plane.visible = !value
@export var enabled:bool = true:
	set(value):
		enabled = value
		set_interactables(enabled)
@export var open:bool = false:
	set(value):
		open = value
		if Engine.is_editor_hint():
			flip_editor_helper()
@export var counter_hinged:bool:
	set(value):
		counter_hinged = value
		if Engine.is_editor_hint():
			flip_editor_helper()
@export var locked:bool = false:
	set(value):
		locked = value
		if open: interact()
@export var locked_message:String = ""
@onready var editor_pointer: MeshInstance3D = $EditorPointer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var raytraced_audio_player_3d: RaytracedAudioPlayer3D = $RaytracedAudioPlayer3D

func _ready() -> void:
	flip_editor_helper()
	locked_collision.disabled = !locked

func interact(player:Player = null, _interactable:Interactable = null):
	if locked:
		raytraced_audio_player_3d.stream = DOOR_LOCKED
		raytraced_audio_player_3d.play()
		if player:
			Global.notify_player(locked_message)
			return
	if playing:
		return
	if open:
		open = false
		if interactables.size() > 1 and enabled:
			interactables["open"].enabled = false
			interactables["close"].enabled = true
		else:
			set_interactables(enabled)
		if counter_hinged:
			animation_player.play("door_close_counter_hinged")
		else:
			animation_player.play("door_close")
	else:
		open = true
		if interactables.size() > 1 and enabled:
			interactables["open"].enabled = true
			interactables["close"].enabled = false
		else:
			set_interactables(enabled)
		if counter_hinged:
			animation_player.play("door_open_counter_hinged")
		else:
			animation_player.play("door_open")
	playing = true
	animation_player.animation_finished.connect(func(_notused): playing = false, CONNECT_ONE_SHOT)

func flip_editor_helper():
	if editor_pointer:
		if counter_hinged:
			editor_pointer.position.z = -.7
			editor_pointer.scale.y = -1
		else:
			editor_pointer.position.z = .7
			editor_pointer.scale.y = 1
		if open:
			if interactables.size() > 1 and enabled:
				interactables["open"].enabled = false
				interactables["close"].enabled = true
			else:
				set_interactables(false)
			if!counter_hinged:
				animation_player.play("door_open")
			else:
				animation_player.play("door_open_counter_hinged")
		else:
			if interactables.size() > 1 and enabled:
				interactables["open"].enabled = true
				interactables["close"].enabled = false
			else:
				set_interactables(false)
			if !counter_hinged:
				animation_player.play("door_close")
			else:
				animation_player.play("door_close_counter_hinged")
	
func set_interactables(value:bool):
	for iactable:Interactable in interactables.values():
			iactable.enabled = value

func lock():
	locked = true
	locked_collision.disabled = false
	if open: interact()

func unlock():
	locked = false
	locked_collision.disabled = true
	enabled = true
