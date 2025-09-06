extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

@export var speed = 1.0
var target_position:Vector3

func _ready() -> void:
	target_position = Vector3.ZERO
	updateTargetLocation(target_position)

func _physics_process(delta: float) -> void:
	if position.distance_to(target_position) > 0.5:
		var current_location = global_position
		var next_location = navigation_agent_3d.get_next_path_position()
		if next_location != global_position:
			look_at(next_location)
		rotation.x = 0
		rotation.z = 0
		var new_velocity = (next_location - current_location).normalized() * speed
		velocity = new_velocity
		move_and_slide()

func updateTargetLocation(_target):
	navigation_agent_3d.target_position = _target
	target_position = _target
