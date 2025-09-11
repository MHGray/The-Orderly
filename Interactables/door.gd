@tool
extends Node3D

class_name Door

@onready var plane: MeshInstance3D = $Plane

@export var interactable: Interactable:
	set(value):
		interactable = value
		interactable.enabled = enabled
@export var baking_door:bool:
	set(value):
		baking_door = value
		if plane:
			plane.visible = !value
@export var enabled:bool = true:
	set(value):
		enabled = value
		interactable.enabled = enabled
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
@onready var editor_pointer: MeshInstance3D = $EditorPointer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	flip_editor_helper()

func interact(player:Player, interactable:Interactable):
	if open:
		open = false
		animation_player.play_backwards("door_open")
	else:
		open = true
		animation_player.play("door_open")
	pass

func flip_editor_helper():
	if editor_pointer:
		if counter_hinged:
			editor_pointer.position.z = -.7
			editor_pointer.scale.y = -1
		else:
			editor_pointer.position.z = .7
			editor_pointer.scale.y = 1
		if open and !counter_hinged:
			animation_player.play("door_open")
		elif !open and !counter_hinged:
			animation_player.play_backwards("door_open")
		elif open and counter_hinged:
			animation_player.play("door_open_counter_hinged")
			pass
		elif !open and counter_hinged:
			animation_player.play_backwards("door_open_counter_hinged")
	
