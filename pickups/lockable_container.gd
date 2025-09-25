extends Node3D

class_name LockableContainer

@export var disabled:bool
@export var pickup:Pickup
@export var unlocked_by_key:Global.Key_Type
@export var unlocked_by_tool:Global.Tool_Type

func _ready() -> void:
	Global.event_bus.connect(handle_containers_loaded)

func handle_containers_loaded(bus:Global.BusType, _data):
	if bus == Global.BusType.CONTAINERS_LOADED:
		setup()

func setup() -> void:
	if !pickup:
		for child in get_children():
			if child is Pickup:
				pickup = child
				continue
	if unlocked_by_key == Global.Key_Type.NULL and unlocked_by_tool == Global.Tool_Type.NULL and disabled:
		push_error("Didn't set key or tool on lockable container")
	if !pickup:
			return
	pickup.enabled = !disabled
