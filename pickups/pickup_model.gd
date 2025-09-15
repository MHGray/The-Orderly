extends RigidBody3D

class_name PickupModel

var ITEM_OUTLINE_MAT = load("res://shaders/item_outline_mat.tres")
var ITEM_HIGHLIGHTER_MAT = load("res://shaders/item_highlighter_mat.tres")
@export var pickup:Pickup
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@export var mesh:MeshInstance3D

func _ready() -> void:
	highlight()
	
	if !pickup:
		for child in get_children():
			if child is Pickup:
				pickup = child
	if !pickup:
		push_error("Could not find pickup on pickup model:%s" % str(self))

func highlight():
	if mesh:
		mesh.material_overlay = ITEM_HIGHLIGHTER_MAT
	else:
		push_error("Mesh not set in %s"% self.name)
func outline():
	if mesh:
		mesh.material_overlay = ITEM_OUTLINE_MAT
	else:
		push_error("Mesh not set in %s"% self.name)
func disable():
	if mesh:
		mesh.material_overlay = null
	else:
		push_error("Mesh not set in %s"% self.name)
