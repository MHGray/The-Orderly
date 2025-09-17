extends Node3D

var tween:Tween
@export var bob_time:float
@export var bob_freq:float
@export var bob_amp:float
var start_pos:Vector3

enum slected {}

signal has_died

func _ready() -> void:
	has_died.connect(oh_no.bind("BOB"))
	has_died.connect(condolences)
	
func _on_label_pressed() -> void:
	do_tween(5)
	
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
