extends Node3D

var tween:Tween
@export var bob_time:float
@export var bob_freq:float
@export var bob_amp:float
var start_pos:Vector3

signal has_died

func _ready() -> void:
	has_died.connect(oh_no.bind("BOB"))
	has_died.connect(condolences)
	
func _on_label_pressed() -> void:
	start_pos = position
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.set_loops().set_trans(Tween.TRANS_ELASTIC)
	tween.tween_method(bob_method,0.0,2*PI,bob_time)
	has_died.emit("Stanley")
	pass # Replace with function body.

func bob_method(progress):
	position.y = start_pos.y + sin(progress * bob_freq) * bob_amp
	pass

func _on_label_2_pressed() -> void:
	if tween and tween.is_running():
		tween.kill()
	position = Vector3.ZERO

func oh_no(big_name, second_big_name):
	print_rich("[color=RED][font_size=30]%s DIED, %s is very sad" % [big_name,second_big_name])

func condolences(big_name):
	print_rich("[rainbow][font_size=50][wave amp=500]Welcome to--- the afterlife %s" % big_name)
	
