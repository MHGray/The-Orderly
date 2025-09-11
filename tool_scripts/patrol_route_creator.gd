@tool
extends Node

@export var route_name:String = "temp"
@export var actual_nodes:Array[Node3D]
@export var packed_vectors:PackedVector3Array
var route:PatrolRoute

@export_tool_button("Pack Nodes") var _pack:Callable = pack
@export_tool_button("Save Nodes") var _save:Callable = save

func pack():
	packed_vectors = []
	for node:Node3D in actual_nodes:
		packed_vectors.append(node.global_position)
	route = PatrolRoute.new()
	route.points = packed_vectors

func save():
	var save_loc = "res://resources/patrol_routes/%s.tres" % route_name
	var error = ResourceSaver.save(route, save_loc)
	print(error)
