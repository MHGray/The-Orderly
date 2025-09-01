extends CharacterBody3D

@export var life:float = 2
@export var rise_speed:float
@export var scale_range:Vector2
var max_scale:Vector3

func _ready() -> void:
	var max = randf_range(scale_range.x,scale_range.y)
	max_scale = Vector3(max,max,max)
	var tween:Tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", max_scale, life)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	life -= delta
	if life <= 0:
		queue_free()
	position.y += delta * rise_speed / scale.length()

func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		queue_free()
