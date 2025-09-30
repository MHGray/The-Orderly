extends Area3D

@onready var skybox: Node3D = $skybox
func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		Global.player_in_garden(true)
		skybox.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		Global.player_in_garden(false)
		skybox.visible = false
