extends Node3D

var tween:Tween
@export var bob_time:float
@export var bob_freq:float
@export var bob_amp:float
var start_pos:Vector3
var player:Player
enum slected {}

signal has_died
signal loaded

func _ready() -> void:
	player = get_tree().get_nodes_in_group("player").front()
	has_died.connect(oh_no.bind("BOB"))
	has_died.connect(condolences)
	loaded.emit()
	
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
	var min = aabb.position
	var max = aabb.position + aabb.size
	return Vector3(
		clamp(p.x, min.x, max.x),
		clamp(p.y, min.y, max.y),
		clamp(p.z, min.z, max.z)
	)

func look_at_closest_point(player: Node3D, shelf: MeshInstance3D) -> void:
	# shelf must expose an AABB (usually a MeshInstance3D: get_aabb())
	var aabb: AABB = shelf.get_aabb()
	var player_local: Vector3 = shelf.to_local(player.global_transform.origin)
	var closest_local: Vector3 = aabb_closest_point(aabb, player_local)
	var closest_global: Vector3 = shelf.to_global(closest_local)

	# avoid zero-length look_at (player inside the box)
	if player.global_transform.origin.distance_to(closest_global) < 0.001:
		closest_global += shelf.global_transform.basis.z * 0.001

	player.look_at(closest_global, Vector3.UP)
