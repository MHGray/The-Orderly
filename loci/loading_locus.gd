extends Node3D
class_name LoadingScreen

const LOADING_LOCUS = preload("res://loci/loading_locus.tscn")

@onready var progress_bar: ProgressBar = $Control/ProgressBar
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var control: Control = $Control
@onready var thing_holder: Node = $ThingHolder
@onready var camera_3d: Camera3D = $Camera3D

@export var spatial_materials: Array[ShaderMaterial]
@export var canvas_materials: Array[ShaderMaterial]
@export var everything: Array[PackedScene]
@export var scene_to_load: String

var initial_size: int
var progress: Array = []
var scene_load_status: ResourceLoader.ThreadLoadStatus
var last_thing_loaded: Node

static func create(no_preload_shaders: bool = false):
	var scene = LOADING_LOCUS.instantiate()
	if no_preload_shaders:
		scene.spatial_materials.clear()
		scene.canvas_materials.clear()
	return scene

func _ready() -> void:
	initial_size = spatial_materials.size() + canvas_materials.size() + everything.size()
	ResourceLoader.load_threaded_request(scene_to_load)
	# Kick off warm-up as a coroutine
	_warmup()

# Coroutine to step through assets one per frame
func _warmup() -> void:
	await get_tree().process_frame  # ensure scene tree is ready

	while spatial_materials.size() > 0:
		var mat = spatial_materials.pop_back()
		mesh_instance_3d.visible = true
		mesh_instance_3d.material_override = mat
		RenderingServer.force_draw()
		await get_tree().process_frame

	while canvas_materials.size() > 0:
		var mat = canvas_materials.pop_back()
		control.visible = true
		control.material = mat
		RenderingServer.force_draw()
		await get_tree().process_frame

	while everything.size() > 0:
		var thing_scene = everything.pop_back()
		if last_thing_loaded:
			last_thing_loaded.queue_free()
		last_thing_loaded = thing_scene.instantiate()
		thing_holder.add_child(last_thing_loaded)
		last_thing_loaded.global_position = Vector3.ZERO
		camera_3d.look_at(last_thing_loaded.global_position)
		RenderingServer.force_draw()
		await get_tree().process_frame

	# Warm-up finished → try to switch scene once resource is ready
	_check_scene_load()

func _process(_delta: float) -> void:
	if progress.size() > 0 and initial_size > 0:
		var done = initial_size - (everything.size() + spatial_materials.size() + canvas_materials.size())
		progress_bar.value = float(done) / initial_size * 100.0

	scene_load_status = ResourceLoader.load_threaded_get_status(scene_to_load, progress)
	# If warm-up has already finished, this will trigger
	if scene_load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED \
	and everything.size() == 0 and spatial_materials.size() == 0 and canvas_materials.size() == 0:
		_check_scene_load()
	elif scene_load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
		push_error("Failed to load: %s" % scene_to_load)

func _check_scene_load() -> void:
	if scene_load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		var new_scene = ResourceLoader.load_threaded_get(scene_to_load) as PackedScene
		var new_node = new_scene.instantiate()
		if scene_to_load == "res://test/test_3d.tscn":
			
			pass
		get_tree().root.add_child(new_node)
		get_tree().current_scene = new_node
		queue_free()
