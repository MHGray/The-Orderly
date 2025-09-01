extends Node3D

const TEAPOT = preload("res://teapot.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in 100:
		var tpot = TEAPOT.instantiate()
		tpot.position = Vector3(randf_range(0,15),randf_range(0,15),randf_range(0,15))
		add_child(tpot)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
