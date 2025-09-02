extends Area3D

class_name Pickup

enum Type {NULL, GATE_KEY}

@export var item:Type
@export var alternate_return_on_pickup:Node
@export var custom_pickup:Node

func _ready() -> void:
	print(name)

func pickup(_player:Player):
	if custom_pickup:
		return custom_pickup.pickup()
	if alternate_return_on_pickup:
		return alternate_return_on_pickup
	return get_parent()
