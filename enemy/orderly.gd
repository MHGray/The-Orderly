extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var player: Player = $"../Player"

@export var speed = 1.0
var target_position:Vector3
var check_for_player_max:float = 20
var check_for_player:float = check_for_player_max

func _ready() -> void:
	target_position = Vector3.ZERO
	updateTargetLocation(target_position)

func _physics_process(_delta: float) -> void:
	check_for_player -= _delta
	if check_for_player < 0:
		check_for_player = check_for_player_max
		target_position = player.global_position
		updateTargetLocation(target_position)
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
