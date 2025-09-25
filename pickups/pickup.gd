extends Area3D

class_name Pickup

enum Type {NULL, KEY, TOOL}

@export var item:Type
@export var key_type:int
@export var tool_type:int
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
signal dropped

func _ready() -> void:
	for child in get_children():
		if child is CollisionShape3D:
			collision_shape = child
	model = get_parent() if !model_override else model_override

func pickup(_player:Player):
	picked_up.emit()
	model.disable()
	if custom_pickup:
		return custom_pickup.pickup()
	if alternate_return_on_pickup:
		return alternate_return_on_pickup
	return self

func sleep_soon(how_long:float):
	get_tree().create_timer(how_long).timeout.connect(func():
		if model.freeze: return
		var nav_map:RID = get_world_3d().navigation_map
		var closest_point = NavigationServer3D.map_get_closest_point(nav_map,global_position)
		model.global_position = closest_point
		model.linear_velocity = Vector3.ZERO
		model.angular_velocity = Vector3.ZERO
		model.sleeping = true
		model.freeze = true
	)

func shut_up_debugger():
	dropped.emit()
