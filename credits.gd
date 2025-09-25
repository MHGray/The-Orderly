extends ScrollContainer

signal closing

func _on_button_pressed() -> void:
	closing.emit()
	queue_free()
