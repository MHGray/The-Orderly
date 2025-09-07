extends Node3D
class_name LoadingScreen

const LOADING_LOCUS = preload("res://loci/loading_locus.tscn")
@onready var progress_bar: ProgressBar = $Control/ProgressBar
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var control: Control = $Control
@onready var thing_holder: Node = $ThingHolder
@onready var camera_3d: Camera3D = $Camera3D
var initial_size:float

@export var spatial_materials:Array[ShaderMaterial]
@export var canvas_materials:Array[ShaderMaterial]

@export var scene_to_load:String
var progress = []
var scene_load_status: ResourceLoader.ThreadLoadStatus
var preload_shaders:bool = true
var shader_render_time_max:float = .2
var shader_render_time:float = shader_render_time_max
var spatial_material_to_load:ShaderMaterial
var canvas_material_to_load:ShaderMaterial

@export var everything:Array[PackedScene]
var thing_to_load:PackedScene
var last_thing_loaded:Node
static func create(no_preload_shaders:bool = false):
	var scene = LOADING_LOCUS.instantiate()
	if no_preload_shaders:
		scene.preload_shaders = false
	return LOADING_LOCUS.instantiate()

func _ready() -> void:
	initial_size = spatial_materials.size() + canvas_materials.size() + everything.size()
	ResourceLoader.load_threaded_request(scene_to_load)
	
func _process(delta: float) -> void:
	shader_render_time -= delta
	if shader_render_time < 0:
		if spatial_materials.size() > 0 || canvas_materials.size() > 0 || everything.size() > 0:
			shader_render_time = shader_render_time_max
		if spatial_materials.size() > 0:
			spatial_material_to_load = spatial_materials.pop_back()
			mesh_instance_3d.material_overlay = spatial_material_to_load
		if canvas_materials.size() > 0:
			canvas_material_to_load = canvas_materials.pop_back()
			control.material = canvas_material_to_load
		if everything.size() > 0:
			thing_to_load = everything.pop_back()
			var thing = thing_to_load.instantiate()
			if last_thing_loaded:
				last_thing_loaded.visible = false
			last_thing_loaded = thing
			thing_holder.add_child(thing)
			thing.global_position = Vector3.ZERO
			camera_3d.look_at(thing.global_position)
	print(control.material)
	if progress.size() > 0:
		var progress_amount = (initial_size - (everything.size() + spatial_materials.size() + canvas_materials.size()))/initial_size  * 100
		progress_bar.value = progress_amount
	scene_load_status = ResourceLoader.load_threaded_get_status(scene_to_load, progress)
	if scene_load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED and spatial_materials.size() == 0 and canvas_materials.size() == 0 and shader_render_time < 0:
		var new_scene = ResourceLoader.load_threaded_get(scene_to_load) as PackedScene
		get_tree().root.add_child(new_scene.instantiate())
		queue_free()
	elif scene_load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
		pass
