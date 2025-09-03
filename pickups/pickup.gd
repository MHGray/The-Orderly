extends Area3D

class_name Pickup

enum Type {NULL, GATE_KEY}

@export var item:Type
@export var enabled:bool = true
@export var alternate_return_on_pickup:Node
@export var custom_pickup:Node
@export var model_override:Node3D
var model:Node3D

func _ready() -> void:
	model = get_parent() if !model_override else model_override
	print(name)

func pickup(_player:Player):
	if custom_pickup:
		return custom_pickup.pickup()
	if alternate_return_on_pickup:
		return alternate_return_on_pickup
	return self
