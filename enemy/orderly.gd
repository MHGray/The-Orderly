extends CharacterBody3D

class_name Orderly

@export var patrol_routes:Dictionary[PatrolRoutes, PatrolRoute]
@export var starting_patrol_route:PatrolRoute
@onready var interactables_detector: Area3D = $InteractablesDetector

@onready var navigation_agent_3d:NavigationAgent3D = $NavigationAgent3D
@onready var player: Player 

@export_custom(PROPERTY_HINT_NONE,"suffix:m/s") var speed = 1.0
var target_position:Vector3
var state:State
var previous_state:State
var next_state:State
var substate:Substate
var previous_substate:Substate
var next_substate:Substate

@export_custom(PROPERTY_HINT_NONE,"suffix:s") var interact_windup_max:float = 1
var interact_windup:float = interact_windup_max

var nearby_closed_doors:Array[Door] = []
var nearby_opened_doors:Array[Door] = []
@export_custom(PROPERTY_HINT_NONE,"suffix:s") var door_cooldown_max:float = 0.5
var door_cooldown:float = door_cooldown_max

@export var thinking_cooldown_max:float = 2
var thinking_cooldown = thinking_cooldown_max

var next_patrol_point:Vector3 
var current_patrol_route:PatrolRoute

signal patrol_point_reached

enum PatrolRoutes{
	NULL, FIRST_FLOOR, # SECOND_FLOOR, THIRD_FLOOR, BASEMENT, GRAND_TOUR
}
enum State{
	NULL, PATROL, CHASE, INVESTIGATE
}
enum Substate{
	NULL, WALKING, THINKING, OPENING, CLOSING, SEARCHING, LOOKING, MURDERING
}

func _ready() -> void:
	if !starting_patrol_route: return
	next_patrol_point = starting_patrol_route.get_closest_patrol_point(global_position)
	patrol_point_reached.connect(get_next_patrol_point)
	current_patrol_route = starting_patrol_route
	target_position = Vector3.ZERO
	update_target_location(target_position)

func _physics_process(delta: float) -> void:
	## New idea for doors: Nav agent just goes along his path but anytime there
	## is a closed door in the door opener, she stops and opens the door
	## and any time a door would leave the door closer, if it is open, she stops
	## and closes the door
	door_cooldown -= delta
	match(state):
		State.NULL:
			state = State.PATROL
		State.PATROL:
			patrol_process(delta)
		State.CHASE:
			chase_process(delta)
		State.INVESTIGATE:
			investigate_process(delta)

func patrol_process(delta:float):
	if next_substate != Substate.NULL:
		change_state(state, next_substate)
		next_substate = Substate.NULL
	match(substate):
		Substate.NULL:
			substate = Substate.WALKING
		Substate.WALKING:
			var reached_target:bool = move_toward_target()
			if reached_target:
				patrol_point_reached.emit()
				next_substate = Substate.THINKING
		Substate.THINKING:
			thinking_cooldown -= delta
			if thinking_cooldown < 0:
				next_substate = Substate.WALKING
				thinking_cooldown = thinking_cooldown_max
		Substate.OPENING:
			opening_process(delta)
		Substate.MURDERING:
			pass
		Substate.CLOSING:
			closing_process(delta)
		Substate.SEARCHING:
			pass
		Substate.LOOKING:
			pass
func chase_process(delta:float):
	match(substate):
		Substate.NULL:
			substate = Substate.WALKING
		Substate.WALKING:
			pass
		Substate.THINKING:
			pass
		Substate.OPENING:
			opening_process(delta)
		Substate.MURDERING:
			pass
		Substate.CLOSING:
			closing_process(delta)
		Substate.SEARCHING:
			pass
		Substate.LOOKING:
			pass
func investigate_process(delta:float):
	match(substate):
		Substate.NULL:
			substate = Substate.WALKING
		Substate.WALKING:
			pass
		Substate.THINKING:
			pass
		Substate.OPENING:
			opening_process(delta)
		Substate.MURDERING:
			pass
		Substate.CLOSING:
			closing_process(delta)
		Substate.SEARCHING:
			pass
		Substate.LOOKING:
			pass

func move_toward_target() -> bool:
	if global_position.distance_to(target_position) > 1:
		var next_location = navigation_agent_3d.get_next_path_position()
		if !next_location.cross(global_position).is_zero_approx() and\
			!next_location.is_equal_approx(global_position):
			look_at(next_location)
		rotation.x = 0
		rotation.z = 0
		var new_velocity = (next_location - global_position).normalized() * speed
		velocity = new_velocity
		move_and_slide()
		return false
	else:
		return true

func opening_process(delta:float):
	interact_windup -= delta
	if interact_windup < 0:
		interact_windup = interact_windup_max
		open_door()

func closing_process(delta:float):
	interact_windup -= delta
	if interact_windup < 0:
		interact_windup = interact_windup_max
		close_door()

func open_door():
	for door:Door in nearby_closed_doors:
		door.interact()
	nearby_closed_doors = []
	door_cooldown = door_cooldown_max
	interact_windup = interact_windup_max
	if previous_substate == Substate.OPENING or previous_substate == Substate.CLOSING:
		previous_substate = Substate.NULL
	change_state(previous_state,previous_substate)

func close_door():
	for door:Door in nearby_opened_doors:
		door.interact()
	nearby_opened_doors = []
	door_cooldown = door_cooldown_max
	interact_windup = interact_windup_max
	if previous_substate == Substate.OPENING or previous_substate == Substate.CLOSING:
		previous_substate = Substate.NULL
	change_state(previous_state,previous_substate)

func update_target_location(vec3:Vector3):
	navigation_agent_3d.target_position = vec3
	target_position = navigation_agent_3d.get_final_position()

func change_state(_state:State, _substate:Substate):
	var temp_state:State = state
	state = _state
	previous_state = temp_state
	var temp_substate:Substate = substate
	substate = _substate
	previous_substate = temp_substate

func _on_interactables_detector_area_entered(area: Area3D) -> void:
	if area is Interactable and area.node_with_interact_function:
		var parent:Node3D = area.node_with_interact_function as Node3D
		if parent is Door:
			var door:Door = parent
			if door.enabled and !door.open and door_cooldown < 0:
				change_state(state,Substate.OPENING)
				nearby_closed_doors.append(door)


func _on_interactables_detector_area_exited(area: Area3D) -> void:
	if area is Interactable and area.node_with_interact_function:
		var parent:Node3D = area.node_with_interact_function as Node3D
		if parent is Door:
			var door:Door = parent
			if door.enabled and door.open and door_cooldown < 0:
				change_state(state,Substate.CLOSING)
				nearby_opened_doors.append(door)
				

func get_next_patrol_point():
	next_patrol_point = current_patrol_route.get_next_patrol_point()
	update_target_location(next_patrol_point)

	
