extends Node3D

var tween:Tween
@export var bob_time:float
@export var bob_freq:float
@export var bob_amp:float
var start_pos:Vector3
@export var player:Player

signal has_died

func _ready() -> void:
	has_died.connect(oh_no.bind("BOB"))
	has_died.connect(condolences)
	
func _on_label_pressed() -> void:
	look_at_closest_point($Camera3D,$BigCube)
	
func bob_method(progress):
	position.y = start_pos.y + sin(progress * bob_freq) * bob_amp
	pass

func _on_label_2_pressed() -> void:
	do_tween(2)

func oh_no(big_name, second_big_name):
	print_rich("[color=RED][font_size=30]%s DIED, %s is very sad" % [big_name,second_big_name])

func condolences(big_name):
	print_rich("[rainbow][font_size=50][wave amp=500]Welcome to--- the afterlife %s" % big_name)
	

func do_tween(_val):
	if tween and tween.is_running():
		tween.kill()

func my_func(progress):
	print(progress)

func aabb_closest_point(aabb: AABB, p: Vector3) -> Vector3:
	var _min = aabb.position
	var _max = aabb.position + aabb.size
	return Vector3(
		clamp(p.x, _min.x, _max.x),
		clamp(p.y, _min.y, _max.y),
		clamp(p.z, _min.z, _max.z)
	)

func look_at_closest_point(_player: Node3D, shelf: MeshInstance3D) -> void:
	# shelf must expose an AABB (usually a MeshInstance3D: get_aabb())
	var aabb: AABB = shelf.get_aabb()
	var _player_local: Vector3 = shelf.to_local(_player.global_transform.origin)
	var closest_local: Vector3 = aabb_closest_point(aabb, _player_local)
	var closest_global: Vector3 = shelf.to_global(closest_local)

	# avoid zero-length look_at (_player inside the box)
	if _player.global_transform.origin.distance_to(closest_global) < 0.001:
		closest_global += shelf.global_transform.basis.z * 0.001

	_player.look_at(closest_global, Vector3.UP)
