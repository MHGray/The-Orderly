extends PathFollow3D

signal finished(target:Path3D)

func _process(delta: float) -> void:
	if progress_ratio == 1:
		finished.emit()
