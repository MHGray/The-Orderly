extends Area3D

class_name Pickup

enum Type {NULL, GATE_KEY}

@export var item:Type
@export var enabled:bool:
	set(value):
		enabled = value
		if collision_shape:
			collision_shape.disabled = !value
@export var alternate_return_on_pickup:Node
@export var custom_pickup:Node
@export var model_override:Node3D
var model:PickupModel
var collision_shape:CollisionShape3D

signal picked_up

func _ready() -> void:
	for child in get_children():
		if child is CollisionShape3D:
			collision_shape = child
	model = get_parent() if !model_override else model_override
	print(name)

func pickup(_player:Player):
	picked_up.emit()
	if custom_pickup:
		return custom_pickup.pickup()
	if alternate_return_on_pickup:
		return alternate_return_on_pickup
	return self
