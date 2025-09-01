extends Node3D


const BUBBLE = preload("res://bubble.tscn")
@onready var timer: Timer = $Timer

@export var min_wait:float = .02
@export var max_wait:float = .2

func _ready() -> void:
	timer.timeout.connect(func():
		timer.wait_time = randf_range(min_wait,max_wait)
	)
	timer.timeout.connect(make_bubble)

func make_bubble():
	var bub = BUBBLE.instantiate()
	bub.life = randf_range(2,4)
	bub.rise_speed = randf_range(8,15)
	bub.position = Vector3(randf_range(-3,3),randf_range(0,3),randf_range(-3,3))
	add_child(bub)
