extends CharacterBody3D

class_name Orderly

@export var patrol_routes:Dictionary[PatrolRoutes, PatrolRoute]
@export var starting_patrol_route:PatrolRoute
@onready var interactables_detector: Area3D = $InteractablesDetector
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var killcam: Camera3D = $killcam
@onready var kill_player_animation_player: AnimationPlayer = $KillPlayerAnimationPlayer

@onready var navigation_agent_3d:NavigationAgent3D = $NavigationAgent3D
@onready var player: Player 
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var raytraced_audio_player_3d: RaytracedAudioPlayer3D = $Dying/Skeleton3D/RaytracedAudioPlayer3D

@export_group("👀 Physical 💪")
@export_custom(PROPERTY_HINT_NONE,"suffix:m/s") var walk_speed:float = 1.4
@export_custom(PROPERTY_HINT_NONE,"suffix:m/s") var chase_speed:float = 2.0
var speed:float = walk_speed
@export_custom(PROPERTY_HINT_NONE,"suffix:rads") var hearing_distance_maxs:Dictionary[Player.PlayerNoise.NoiseLevel,float] = {
	Player.PlayerNoise.NoiseLevel.SOFT: 7,
	Player.PlayerNoise.NoiseLevel.AVERAGE: 15,
	Player.PlayerNoise.NoiseLevel.LOUD: 99999
}
@export_custom(PROPERTY_HINT_NONE,"suffix:rads") var vision_angle_maxs:Dictionary[State,float] = {
	State.PATROL:PI/4,
	State.INVESTIGATE:PI/2,
	State.CHASE:PI}
var vision_angle:float = vision_angle_maxs[State.PATROL]
@export_custom(PROPERTY_HINT_NONE,"suffix:m") var vision_distance_patrol:float = 8
@export_custom(PROPERTY_HINT_NONE,"suffix:m") var vision_distance_investigate:float = 10
@export_custom(PROPERTY_HINT_NONE,"suffix:m") var vision_distance_chase:float = 12
@export_custom(PROPERTY_HINT_NONE,"suffix:m") var murder_distance:float = 2
var vision_distance:float = vision_distance_patrol

var target_position:Vector3
var state:State
var previous_state:State
var next_state:State
@export var substate:Substate
var previous_substate:Substate
var next_substate:Substate

@export_group("✋ Interaction ✋")
@export_custom(PROPERTY_HINT_NONE,"suffix:s") var interact_windup_max:float = 1
var interact_windup:float = interact_windup_max

var nearby_doors:Array[Door] = []
var doors_to_close:Array[Door] = []
@export_custom(PROPERTY_HINT_NONE,"suffix:s") var door_cooldown_max:float = 0.5
var door_cooldown:float = door_cooldown_max

@export var thinking_cooldown_max:float = 2
var thinking_cooldown = thinking_cooldown_max

var next_patrol_point:Vector3 
var current_patrol_route:PatrolRoute

var player_last_known_position:Vector3
@export var chase_timer_max:float = 20
var chase_timer:float = chase_timer_max
var random_nearby_point:Vector3
var player_started_hiding:bool = false
var player_is_hidden:bool = false
var saw_player_hide:bool = false
var heard_noise:Player.PlayerNoise

var dying:bool = false
var breakdance:bool = false

signal patrol_point_reached

enum PatrolRoutes{
	NULL, FIRST_FLOOR, # SECOND_FLOOR, THIRD_FLOOR, BASEMENT, GRAND_TOUR
}
enum State{
	NULL, PATROL, INVESTIGATE, CHASE
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
	animation_tree.set("parameters/TimeScale/scale",speed)
	Global.event_bus.connect(handle_event_bus_messages)
	
func _physics_process(delta: float) -> void:
	door_cooldown -= delta
	if Input.is_action_just_pressed("debug_action"):
		murder_player()
	if check_to_murder_player() and substate != Substate.MURDERING:
		murder_player()
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
	chase_timer = chase_timer_max
	if next_substate != Substate.NULL:
		change_state(state, next_substate)
		next_substate = Substate.NULL
	if heard_noise:
		change_state(State.INVESTIGATE, Substate.WALKING)
	match(substate):
		Substate.NULL:
			substate = Substate.WALKING
		Substate.WALKING:
			set_anim_tree(1)
			var reached_target:bool = move_toward_target()
			if look_for_player():
				change_state(State.CHASE, Substate.WALKING)
				return
			if reached_target:
				patrol_point_reached.emit()
				next_substate = Substate.THINKING
		Substate.THINKING:
			set_anim_tree(0)
			if look_for_player():
				change_state(State.CHASE, Substate.WALKING)
				return
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
			change_state(state,Substate.NULL)
		Substate.LOOKING:
			change_state(state,Substate.NULL)
func investigate_process(delta:float):
	chase_timer -= delta
	if chase_timer < 0:
		change_state(State.PATROL, Substate.WALKING)
	if next_substate != Substate.NULL:
		change_state(state, next_substate)
		next_substate = Substate.NULL
	if heard_noise:
		update_target_location(heard_noise.location)
		heard_noise = null
	match(substate):
		Substate.NULL:
			substate = Substate.WALKING
		Substate.WALKING:
			set_anim_tree(1)
			chase_timer = chase_timer_max/3.0
			var reached_target:bool = move_toward_target()
			if look_for_player():
				change_state(State.CHASE, Substate.WALKING)
				return
			if reached_target:
				next_substate = Substate.LOOKING
		Substate.THINKING:
			set_anim_tree(0)
			if look_for_player():
				change_state(State.CHASE, Substate.WALKING)
			pass
		Substate.OPENING:
			set_anim_tree(0)
			opening_process(delta)
		Substate.MURDERING:
			pass
		Substate.CLOSING:
			set_anim_tree(0)
			closing_process(delta)
		Substate.SEARCHING:
			set_anim_tree(1)
			var reached_target:bool = move_toward_target()
			if reached_target:
				change_state(State.INVESTIGATE,Substate.LOOKING)
		Substate.LOOKING:
			set_anim_tree(0)
			thinking_cooldown -= delta
			if can_track_player():
				chase_timer = chase_timer_max
				change_state(State.CHASE,Substate.WALKING)
			if thinking_cooldown < 0:
				thinking_cooldown = thinking_cooldown_max
				update_target_location(get_close_by_point())
				change_state(State.INVESTIGATE,Substate.SEARCHING)
func chase_process(delta:float):
	chase_timer -= delta
	if chase_timer < 0:
		change_state(State.PATROL, Substate.WALKING)
		return
	if heard_noise:
		update_target_location(heard_noise.location)
		heard_noise = null
	match(substate):
		Substate.NULL:
			substate = Substate.WALKING
		Substate.WALKING:
			set_anim_tree(1)
			var tar_pos:Vector3 = global_position
			if can_track_player():
				tar_pos = player.global_position
				chase_timer = chase_timer_max
			else:
				tar_pos = player_last_known_position
			update_target_location(tar_pos)
			var reached_target:bool = move_toward_target()
			if reached_target:
				change_state(State.CHASE,Substate.LOOKING)
		Substate.THINKING:
			set_anim_tree(0)
			change_state(State.CHASE, Substate.LOOKING)
		Substate.OPENING:
			set_anim_tree(0)
			opening_process(delta)
		Substate.MURDERING:
			pass
		Substate.CLOSING:
			set_anim_tree(0)
			closing_process(delta)
		Substate.SEARCHING:
			set_anim_tree(1)
			var reached_target:bool = move_toward_target()
			if reached_target:
				change_state(State.CHASE,Substate.LOOKING)
		Substate.LOOKING:
			set_anim_tree(0)
			thinking_cooldown -= delta
			if can_track_player():
				chase_timer = chase_timer_max
				change_state(State.CHASE,Substate.WALKING)
			if thinking_cooldown < 0:
				thinking_cooldown = thinking_cooldown_max
				update_target_location(get_close_by_point())
				change_state(State.CHASE,Substate.SEARCHING)

func get_close_by_point(min_dist:float = 2,dist:float = 7) -> Vector3:
	var new_x:float = randf_range(min_dist,dist)
	var new_y:float = randf_range(min_dist,dist)
	new_x = new_x if randi_range(0,1) == 0 else -new_x
	new_y = new_y if randi_range(0,1) == 0 else -new_y
	return Vector3(global_position.x + new_x,global_position.y, global_position.z + new_y)

func move_toward_target() -> bool:
	if global_position.distance_to(target_position) > 1:
		var next_location = navigation_agent_3d.get_next_path_position()
		if !next_location.cross(global_position).is_zero_approx() and\
			!next_location.is_equal_approx(global_position):
			var prev_rot:Vector3 = rotation
			look_at(next_location)
			var target_rotation:Vector3 = shortest_rotation_path(prev_rot,rotation)
			rotation = prev_rot.move_toward(target_rotation,.1)
			
		rotation.x = 0
		rotation.z = 0
		var new_velocity = (next_location - global_position).normalized() * speed
		velocity = velocity.move_toward(new_velocity,.25)
		move_and_slide()
		return false
	else:
		return true
		
func get_next_patrol_point():
	next_patrol_point = current_patrol_route.get_next_patrol_point()
	update_target_location(next_patrol_point)

func set_closest_patrol_point():
	next_patrol_point = current_patrol_route.get_closest_patrol_point(global_position)
	update_target_location(next_patrol_point)

func update_target_location(vec3:Vector3):
	navigation_agent_3d.target_position = vec3
	target_position = navigation_agent_3d.get_final_position()
	
func look_for_player()	-> bool:
	if !player:
		Global.ping_player()
		return false
		
	if global_position.distance_to(player.global_position) > vision_distance:
		return false
		
	ray_cast_3d.target_position.z = -vision_distance
	ray_cast_3d.look_at(player.camera_3d.global_position)
	
	if abs(ray_cast_3d.rotation.y) > vision_angle:
		return false
	
	var collided_with:Node3D = ray_cast_3d.get_collider()
	if collided_with and collided_with is Player and !player_is_hidden:
		return true
	return false

func can_track_player() -> bool:
	if global_position.distance_to(player.global_position) > vision_distance:
		return false
	
	ray_cast_3d.target_position.z = -vision_distance
	ray_cast_3d.look_at(player.camera_3d.global_position)
	ray_cast_3d.force_raycast_update()
	
	var collided_with:Node3D = ray_cast_3d.get_collider()
	if collided_with and collided_with is Player:
		if player_is_hidden and chase_timer_max - chase_timer > 1:
			return false
		player_last_known_position = player.global_position
		return true
	return false

func opening_process(delta:float):
	set_anim_tree(0)
	interact_windup -= delta
	if interact_windup < 0:
		interact_windup = interact_windup_max
		open_door()

func closing_process(delta:float):
	set_anim_tree(0)
	interact_windup -= delta
	if interact_windup < 0:
		interact_windup = interact_windup_max
		close_door()

func open_door():
	for door:Door in nearby_doors:
		if door.enabled and !door.open:
			door.interact()
	door_cooldown = door_cooldown_max
	interact_windup = interact_windup_max
	if previous_substate == Substate.OPENING or previous_substate == Substate.CLOSING:
		previous_substate = Substate.NULL
	change_state(previous_state,previous_substate)

func close_door():
	for door:Door in doors_to_close:
		if door.enabled and door.open:
			door.interact()
	doors_to_close = []
	door_cooldown = door_cooldown_max
	interact_windup = interact_windup_max
	if previous_substate == Substate.OPENING or previous_substate == Substate.CLOSING:
		previous_substate = Substate.NULL
	change_state(previous_state,previous_substate)

func change_state(_state:State, _substate:Substate):
	var temp_state:State = state
	state = _state
	previous_state = temp_state
	var temp_substate:Substate = substate
	substate = _substate
	previous_substate = temp_substate
	
	vision_angle = vision_angle_maxs[state]
	match(state):
		State.PATROL:
			vision_distance = vision_distance_patrol
			speed = walk_speed
		State.INVESTIGATE:
			vision_distance = vision_distance_investigate
			speed = walk_speed
		State.CHASE:
			vision_distance = vision_distance_chase
			speed = chase_speed
			
func _on_interactables_detector_area_entered(area: Area3D) -> void:
	if area is Interactable and area.node_with_interact_function and area.enabled:
		var parent:Node3D = area.node_with_interact_function as Node3D
		if parent is Door and door_cooldown < 0:
			var door:Door = parent
			if !door.open:
				change_state(state,Substate.OPENING)
				nearby_doors.append(door)

func _on_interactables_detector_area_exited(area: Area3D) -> void:
	if area is Interactable and area.node_with_interact_function and area.enabled:
		var parent:Node3D = area.node_with_interact_function as Node3D
		if parent is Door:
			var door:Door = parent
			if nearby_doors.has(door):
				nearby_doors.erase(door)
			if door.open:
				doors_to_close.append(door)
				change_state(state,Substate.CLOSING)
				
func set_anim_tree(value:float):
	var tween:Tween = create_tween()
	tween.tween_property(animation_tree,"parameters/AnimationNodeStateMachine/BlendSpace1D/blend_position", value, 0.5)

func handle_player_start_hiding():
	player_started_hiding = true
	get_tree().create_timer(1).timeout.connect(func():
		if player_started_hiding:
			if can_track_player():
				saw_player_hide = true
			player_is_hidden = true
			player_started_hiding = false
	)
	
func handle_player_stop_hiding():
	player_started_hiding = false
	player_is_hidden = false
	saw_player_hide = false
	
func handle_event_bus_messages(bus_type:Global.BusType, data:Variant):
	if bus_type == Global.BusType.ORDERLY_GET_PLAYER:
		if !player:
			player = data
			player.made_noise.connect(handle_event_bus_messages)
			player.started_hiding.connect(handle_player_start_hiding)
			player.stopped_hiding.connect(handle_player_stop_hiding)
	if bus_type == Global.BusType.PLAYER_MADE_NOISE:
		var noise = data
		if global_position.distance_to(noise.location) > hearing_distance_maxs[noise.intensity]:
			return
		heard_noise = noise
		player_last_known_position = heard_noise.location

func shortest_rotation_path(from_rotation: Vector3, to_rotation: Vector3) -> Vector3:
	var normalize_angle_diff:Callable = func(angle_diff: float) -> float:
		angle_diff = fmod(angle_diff + PI, TAU)
		if angle_diff < 0:
			angle_diff += TAU
		return angle_diff - PI

	var delta:Vector3 = to_rotation - from_rotation
	delta.x = normalize_angle_diff.call(delta.x)
	delta.y = normalize_angle_diff.call(delta.y)
	delta.z = normalize_angle_diff.call(delta.z)
	return from_rotation + delta

func check_to_murder_player() -> bool:
	if !player: return false
	$DebugLable.debuglabel_4.text = ""
	
	if player.global_position.distance_to(global_position) > murder_distance:
		$DebugLable.debuglabel_4.text += "Too far away"
		return false
	if player_is_hidden and !saw_player_hide:
		$DebugLable.debuglabel_4.text += "\nplayer is hidden"
		return false
	return true

func murder_player():
	player.prepare_to_die()
	substate = Substate.MURDERING
	align_kill_cam()
	kill_player_animation_player.play("murder_standing_player")

func align_kill_cam():
	var tween:Tween = create_tween()
	tween.tween_method(move_cam_to_kill_cam,0.0,2.0,1)
	tween.finished.connect(func():
		killcam.make_current()
		#prints(killcam.rotation, player.camera_3d.global_rotation)
		#prints.call_deferred(killcam.global_rotation, player.camera_3d.global_rotation,"<rotation - position>",killcam.global_position, player.camera_3d.global_position)
		#prints.call_deferred(killcam.global_position, player.camera_3d.global_position)
		prior_to_kill_cam.transform = prior_to_kill_cam_transform
		
	)

var prior_to_kill_cam:Camera3D
var prior_to_kill_cam_transform:Transform3D

func move_cam_to_kill_cam(progress):
	#prints(killcam.rotation, player.camera_3d.global_rotation)
	var cam:Camera3D = get_viewport().get_camera_3d()
	if !prior_to_kill_cam_transform:
		prior_to_kill_cam = cam
		prior_to_kill_cam_transform = cam.transform
	
	cam.global_position = cam.global_position.move_toward(killcam.global_position,progress)
	var tar_rot:Vector3 = shortest_rotation_path(cam.global_rotation, killcam.global_rotation)
	cam.global_rotation = cam.global_rotation.move_toward(tar_rot, progress)
	
func vary_footstep_pitch():
	raytraced_audio_player_3d.pitch_scale = randf_range(.92,1.07)
