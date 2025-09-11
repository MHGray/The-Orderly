extends CharacterBody3D

class_name Orderly

@export var patrol_routes:Dictionary[PatrolRoutes, Array]

@onready var navigation_agent_3d:NavigationAgent3D = $NavigationAgent3D
@onready var player: Player 

@export var speed = 1.0
var target_position:Vector3
@export var check_for_player_max:float = 20
var check_for_player:float = check_for_player_max
var state:State
var patrol_state:PatrolState
var chase_state:ChaseState
var investigate_state:InvestigateState

enum PatrolRoutes{
	NULL, FIRST_FLOOR, SECOND_FLOOR, THIRD_FLOOR, BASEMENT, GRAND_TOUR
}
enum State{
	NULL, PATROL, CHASE, INVESTIGATE
}
enum PatrolState{
	NULL, WALKING, THIKNING, OPENING, CLOSING
}
enum ChaseState{
	NULL, STALKING
}
enum InvestigateState{
	NULL, WALKING, LOOKING, THINKING
}


func _ready() -> void:
	target_position = Vector3.ZERO
	updateTargetLocation(target_position)

func _physics_process(_delta: float) -> void:
	## New idea for doors: Nav agent just goes along his path but anytime there
	## is a closed door in the door opener, she stops and opens the door
	## and any time a door would leave the door closer, if it is open, she stops
	## and closes the door
	match(state):
		State.NULL:
			state = State.PATROL
		State.PATROL:
			patrol_process()
		State.CHASE:
			chase_process()
		State.INVESTIGATE:
			investigate_process()
		
	check_for_player -= _delta
	if check_for_player < 0:
		check_for_player = check_for_player_max
		if !player:
			player = $"../Player"
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

func patrol_process():
	pass
func chase_process():
	pass
func investigate_process():
	pass
