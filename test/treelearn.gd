extends Node3D

var move_horiz:bool = false
var timer:float = 2

func _process(delta: float) -> void:
	timer -= delta
	if timer < 0:
		timer = 2
		move_horiz = !move_horiz
