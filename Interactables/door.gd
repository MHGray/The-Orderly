@tool
extends Node3D

class_name Door

@onready var plane: MeshInstance3D = $Plane

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
@onready var editor_pointer: MeshInstance3D = $EditorPointer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	flip_editor_helper()

func interact(_player:Player = null, _interactable:Interactable = null):
	if open:
		open = false
		if interactables.size() > 1 and enabled:
			interactables["open"].enabled = false
			interactables["close"].enabled = true
		else:
			set_interactables(enabled)
		if counter_hinged:
			animation_player.play_backwards("door_open_counter_hinged")
		else:
			animation_player.play_backwards("door_open")
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
				animation_player.play_backwards("door_open")
			else:
				animation_player.play_backwards("door_open_counter_hinged")
	
func set_interactables(value:bool):
	for iactable:Interactable in interactables.values():
			iactable.enabled = value
