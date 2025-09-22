extends Node3D

@export var disabled:bool
@export var pickup:Pickup
@export var unlocked_by_key:Global.Key_Type
@export var unlocked_by_tool:Global.Tool_Type

@onready var placeholder: Node3D = $placeholder

func _ready() -> void:
	placeholder.queue_free()
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
