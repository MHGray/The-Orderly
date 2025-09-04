extends RigidBody3D

class_name PickupModel

@export var pickup:Pickup
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	if !pickup:
		for child in get_children():
			if child is Pickup:
				pickup = child
	if !pickup:
		push_error("Could not find pickup on pickup model:%s" % str(self))
