extends CharacterBody3D
class_name Player
const PAUSE_MENU = preload("res://menus/pause_menu.tscn")
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var pickup_prompt: RichTextLabel = $CanvasLayer/Control/PickupPrompt
@onready var pickups_probe: Area3D = $Neck/Head/Camera3D/PickupsProbe
@onready var interactables_probe: Area3D = $Neck/Head/Camera3D/InteractablesProbe
@onready var camera_3d: Camera3D = $Neck/Head/Camera3D
@onready var interactable_prompt: RichTextLabel = $"CanvasLayer/Control/Interactable Prompt"
@onready var notice: RichTextLabel = $CanvasLayer/Control/Notification
@onready var neck_ref: Marker3D = $NeckRef
@onready var crouch_neck: Marker3D = $CrouchNeck
@onready var neck: Marker3D = $Neck
@onready var head: Marker3D = $Neck/Head
@onready var shape_cast_3d: ShapeCast3D = $ShapeCast3D
@onready var hand_position: Marker3D = $Neck/Head/Camera3D/hand_position
@onready var flashlight: SpotLight3D = $Neck/Head/Camera3D/FlashlightTarget/flashlight
@onready var debug_label: Label = $"CanvasLayer/Control/Debug Label"
@onready var blinders: ColorRect = $CanvasLayer/Control/Blinders
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var audio_listener_3d: AudioListener3D = $Neck/Head/Camera3D/AudioListener3D

# TODO
# The overlay for the white fuzz might need to be a bit more subtle.
# Sprinting should force you to stand

@export_category("🕷 Spidey Sense 🕷")
@onready var spidey_sense: TextureRect = $CanvasLayer/Control/SpideySense
@export var spidey_base_vignette:float
@export var spidey_max_vignette:float
var spidey_vignette:float = spidey_base_vignette:
	set(val):
		spidey_vignette = val
		spidey_sense.modulate.a = val
		

@export_category("🏃‍♀️ Movement 🏃‍♀️")
@export var SPEED = 5.0
@export var headbob_amp:float = 0.05
@export var headbob_freq:float = 7.0
@export var flashlight_amp:float = 0.05
@export var flashlight_freq:float = 7.0
@export var crouch_height:float = 0.75
@export var stand_height:float = 1.5
@export var crouch_duration:float = 0.5
@export var crouch_speed:float = 0.75
@export var footstep_base_db:float = 1
@export var footstep_db_mod:float = 20

@export var spawn_point:Node3D

var last_pos:Vector3
var bob_val:float = 0
const JUMP_VELOCITY = 4.5
var mouse_move:Vector2 = Vector2.ZERO
@export var max_sprint = 3.0
@export var acceleration:float = 1
var sprint = 1.0

@export_category("🚪 Interactables 🚪")
var interactables:Array[Interactable] = []
var pickups:Array[Pickup] = []
var notice_time:float = 0
@export var notice_time_max:float = 1
@export var default_interact_notice:String = "Press [E] or [Space] to interact"

var holding_object:Pickup
var pickup_tween:Tween
var crouch_tween:Tween
var hiding_camera:Camera3D
var hiding_exit_callable:Callable

enum State{
	NULL, WALKING, CROUCH_WALKING, HIDING, PAUSE, DYING
}

var state_before_pause:State
var state:State = State.WALKING

signal made_noise
signal started_hiding
signal stopped_hiding

func player_made_noise(noise:PlayerNoise):
	made_noise.emit(Global.BusType.PLAYER_MADE_NOISE, noise)

func _ready() -> void:
	if !OS.is_debug_build():
		debug_label.visible = false
	camera_3d.current = true
	Global.event_bus.connect(handle_global_events)
	Global.give_orderly_player(self)
	make_camera_current()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	stand()
	global_position = spawn_point.global_position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and state != State.PAUSE:
		var amount_to_add =  event.relative if event.relative.length() > 1.6 else Vector2.ZERO
		mouse_move += amount_to_add * Global.mouse_sensitivity
	if event.is_action_pressed("ui_left"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("ui_right"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("escape") and state != State.PAUSE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		state_before_pause = state
		state = State.PAUSE
		Engine.time_scale = 0.001
		var menu = PAUSE_MENU.instantiate()
		menu.player = self
		canvas_layer.add_child(menu)
	if event.is_action_pressed("click") and state != State.PAUSE and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		mouse_move = Vector2.ZERO
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta:float) -> void:
	debug_label.text = "Is player's audio listener current? %s" % audio_listener_3d.current
	if state == State.PAUSE: return
	var right_stick_vector:Vector2 = Input.get_vector("right_stick_left","right_stick_right","right_stick_down","right_stick_up")
	if right_stick_vector.length() > 0.2:
		mouse_move += right_stick_vector * delta*2
	

func _physics_process(delta: float) -> void:
	debug_label.text = str(pickups)
	bob_head()
	notice_time -= delta
	if (notice.visible and notice_time < 0) or state == State.DYING:
		notice.visible = false
	match(state):
		State.DYING:
			return
		State.WALKING:
			walking_process(delta)
		State.CROUCH_WALKING:
			crouch_walking_process(delta)
		State.HIDING:
			hiding_process(delta)
		State.PAUSE:
			pass

func handle_interacts_and_pickups():
	if Input.is_action_just_pressed("e"):
		if pickups.size() > 0:
			pickup()
		elif interactables.size() > 0:
			activate()
	
	if pickups.size() > 0:
		sort_pickups()
		for i in pickups.size():
			if i == 0:
				pickups[i].model.outline()
			else:
				pickups[i].model.highlight()
		pickup_prompt.visible = true
		interactable_prompt.visible = false
	elif interactables.size() > 0:
		pickup_prompt.visible = false
		sort_interactables()
		if interactables[0].custom_interact_message:
			interactable_prompt.text = interactables[0].custom_interact_message
		else:
			interactable_prompt.text = default_interact_notice
		interactable_prompt.visible =true
	else:
		pickup_prompt.visible = false
		interactable_prompt.visible = false
func premove(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("c") and state == State.WALKING:
		crouch()
	elif Input.is_action_just_pressed("c") and state == State.CROUCH_WALKING:
		stand()
	if Input.is_action_just_pressed("shift") and state == State.CROUCH_WALKING:
		stand()
	if Input.is_action_pressed("shift") and state == State.WALKING and velocity.length() > 0.1:
		sprint = clamp(sprint + (delta * acceleration), 1, max_sprint)
	else:
		sprint = clamp(sprint - (delta * acceleration), 1, max_sprint)
	
	if Input.is_action_just_pressed("click") and holding_object:
		drop_held_object(6)
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	if Input.is_action_just_pressed("f"):
		toggle_flashlight()

func move():
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (camera_3d.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED * sprint
		velocity.z = direction.z * SPEED * sprint
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if sprint == max_sprint:
		player_made_noise(PlayerNoise.create(global_position,PlayerNoise.NoiseLevel.AVERAGE))
	elif sprint >= SPEED and velocity.length() > 1:
		player_made_noise(PlayerNoise.create(global_position,PlayerNoise.NoiseLevel.SOFT))
		
	
	move_and_slide()
	
	bob_val += global_position.distance_to(last_pos)
	last_pos = global_position

func crouch():
	state = State.CROUCH_WALKING
	var cap = collision_shape_3d.shape as CapsuleShape3D
	if crouch_tween and crouch_tween.is_running():
		crouch_tween.kill()
	crouch_tween = create_tween()
	crouch_tween.set_ease(Tween.EASE_OUT)
	crouch_tween.tween_property(cap, "height", crouch_height,crouch_duration)
	crouch_tween.parallel().tween_property(neck, "position", crouch_neck.position,crouch_duration)
	
func stand():
	shape_cast_3d.force_shapecast_update()
	if shape_cast_3d.get_collision_count() > 0:
		return
	head.reparent(neck)
	state = State.WALKING
	var cap = collision_shape_3d.shape as CapsuleShape3D
	if crouch_tween and crouch_tween.is_running():
		crouch_tween.kill()
	crouch_tween = create_tween()
	crouch_tween.set_ease(Tween.EASE_OUT)
	crouch_tween.tween_property(cap, "height",stand_height,crouch_duration)
	crouch_tween.parallel().tween_property(neck, "position", neck_ref.position,crouch_duration)
	sprint = 1.0

func start_hiding(_hiding_camera:Camera3D, exit_callback:Callable):
	state = State.HIDING
	hiding_camera = _hiding_camera
	hiding_camera.make_current()
	hand_position.visible = false
	hiding_exit_callable = exit_callback
	flashlight.set_layer_mask_value(1,false)
	started_hiding.emit()
	
func stop_hiding(player_state_before_hide:Player.State):
	state = player_state_before_hide
	if hiding_camera:
		hiding_camera.current = false
	camera_3d.make_current()
	hand_position.visible = true
	flashlight.set_layer_mask_value(1,true)
	hiding_camera = null
	stopped_hiding.emit()

func toggle_flashlight():
	flashlight.set_layer_mask_value(1,!flashlight.get_layer_mask_value(1))

func turn_on_flashlight():
	flashlight.set_layer_mask_value(1,true)

func walking_process(delta:float):
	premove(delta)
	handle_interacts_and_pickups()
	mouse_look()
	move()
	
func crouch_walking_process(delta:float):
	premove(delta)
	sprint = crouch_speed
	handle_interacts_and_pickups()
	mouse_look()
	move()

func hiding_process(_delta:float):
	if Input.is_action_just_pressed("e"):
		hiding_exit_callable.call()
	mouse_look(hiding_camera)

func bob_head():
	var prior_y:float = head.position.y
	head.position.y = sin(bob_val*headbob_freq) * -headbob_amp
	if prior_y < 0 and head.position.y > 0 and is_on_floor():
		audio_stream_player_3d.pitch_scale = randf_range(.95,1.07)
		if sprint > SPEED:
			audio_stream_player_3d.volume_db = -45
			audio_stream_player_3d.unit_size = 10
		elif sprint == SPEED:
			audio_stream_player_3d.volume_db = -45
			audio_stream_player_3d.unit_size = 5
		elif sprint < SPEED:
			audio_stream_player_3d.volume_db = -72
			audio_stream_player_3d.unit_size = 5
			
		audio_stream_player_3d.play()
	flashlight.rotation.x = sin(bob_val*flashlight_freq/2.0) * -flashlight_amp
	flashlight.rotation.y = cos(bob_val*flashlight_freq/7.0) * -flashlight_amp

func lock():
	state = State.DYING

func unlock():
	state = State.WALKING
	mouse_move = Vector2.ZERO

func mouse_look(camera:Camera3D = camera_3d):
	if state == State.DYING:
		return
	if !camera:
		camera = camera_3d
	camera.rotation.y -= mouse_move.x
	camera.rotation.x -= mouse_move.y
	camera.rotation.x = clampf(camera.rotation.x, -PI/3, PI/3)
	mouse_move = Vector2.ZERO

func activate():
	var interactable:Area3D
	interactables = interactables.filter(func(thing): return thing.enabled)
	if interactables.size() == 0:
		return
	if interactables.size() > 1:
		sort_interactables()
	interactable = interactables[0]
	if interactable.has_method("interact"):
		interactable.interact(self)
	else:
		push_error("Interactable didn't have interact: %S"%interactable)
	reset_interactables.call_deferred()

func pickup():
	var _pickup:Pickup
	pickups = pickups.filter(func(thing): return thing.enabled)
	if pickups.size() == 0:
		return
	if pickups.size() > 1:
		pickups.sort_custom(func(a:Node3D,b:Node3D):
			return pickups_probe.global_position.distance_squared_to(a.global_position) <\
			 pickups_probe.global_position.distance_squared_to(b.global_position)
		)
	_pickup = pickups[0]
	if _pickup.has_method("pickup"):
		_pickup = _pickup.pickup(self)
	else:
		push_error("Interactable didn't have interact: %S"%_pickup)
		return
		
	var model = _pickup.model as PickupModel
	model.freeze = true
	_pickup.enabled = false
	model.collision_shape_3d.disabled = true
	
	
	drop_held_object(1)
	holding_object = _pickup
	pickup_tween = create_tween()
	pickup_tween.set_ease(Tween.EASE_OUT)
	pickup_tween.tween_method(move_pickup_to_hand.bind(holding_object.global_position),0.0,1.0,.2)
	pickup_tween.finished.connect(func(): 
		holding_object.model.reparent(hand_position)
	)

func drop_held_object(thrust:float = 0) -> PickupModel:
	if pickup_tween and pickup_tween.is_running():
		pickup_tween.kill()
	if holding_object:
		var item = holding_object.model
		holding_object.model.reparent(get_parent())
		holding_object.model.freeze = false
		holding_object.enabled = true
		holding_object.model.collision_shape_3d.disabled = false
		var throw_pos = Vector3(global_position.x,camera_3d.global_position.y,global_position.z)
		holding_object.model.global_position = throw_pos
		holding_object.model.linear_velocity = -camera_3d.global_transform.basis.z * thrust
		holding_object.sleep_soon(5)
		holding_object.dropped.emit()
		holding_object = null
		player_made_noise(PlayerNoise.create(global_position,PlayerNoise.NoiseLevel.AVERAGE))
		return item
	return null

func move_pickup_to_hand(progress, _original_position):
	holding_object.model.global_position = holding_object.model.global_position.lerp(hand_position.global_position,progress)
	holding_object.model.global_rotation = holding_object.model.rotation.slerp(hand_position.global_rotation, progress)
	
func handle_global_events(type:Global.BusType, data = null):
	match(type):
		Global.BusType.PLAYER_NOTIFICATION:
			notice.text = "[center]" + data
			notice.visible = true
			notice_time = notice_time_max
		Global.BusType.PING_PLAYER:
			Global.give_orderly_player(self)

func _on_interactables_probe_area_entered(area: Area3D) -> void:
	if area.enabled:
		interactables.append(area)

func _on_interactables_probe_area_exited(area: Area3D) -> void:
	if interactables.has(area):
		interactables.erase(area)

func reset_interactables():
	interactables = []
	var areas = interactables_probe.get_overlapping_areas()
	for area in areas:
		interactables.append(area as Interactable)

func sort_interactables():
	interactables.sort_custom(func(a:Node3D,b:Node3D):
		return interactables_probe.global_position.distance_squared_to(a.global_position) < interactables_probe.global_position.distance_squared_to(b.global_position)
	)
func sort_pickups():
	pickups.sort_custom(func(a:Node3D,b:Node3D):
		return pickups_probe.global_position.distance_squared_to(a.global_position) < pickups_probe.global_position.distance_squared_to(b.global_position)
	)
		
func _on_pickups_probe_area_entered(area: Area3D) -> void:
	if area.enabled:
		pickups.append(area)

func _on_pickups_probe_area_exited(area: Area3D) -> void:
	if area is Pickup:
		var _pickup:Pickup = (area as Pickup)
		if _pickup.enabled:
			_pickup.model.highlight()
		else:
			_pickup.model.disable()
	pickups.erase(area)

func resume():
	Engine.time_scale = 1
	state = state_before_pause
	state_before_pause = State.NULL
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func has_key(type:Global.Key_Type) -> bool:
	if !holding_object:
		return false
	if holding_object.key_type == type:
		return true
	return false

func has_tool(type:Global.Tool_Type) -> bool:
	if !holding_object:
		return false
	if holding_object.tool_type == type:
		return true
	return false

func prepare_to_die():
	change_state.call_deferred(State.DYING)

func next_day():
	stand()
	stop_hiding(State.WALKING)
	spidey_vignette = 0
	if holding_object:
		drop_held_object()
	position = Vector3.ZERO
	rotation = Vector3.ZERO
	hand_position.visible = true
	global_position = spawn_point.global_position
	turn_on_flashlight()
	make_camera_current()

func change_state(_state:State):
	if state == State.DYING:
		camera_3d.position = Vector3.ZERO
		camera_3d.rotation = Vector3.ZERO
	state = _state

func make_camera_current():
	camera_3d.make_current()
	audio_listener_3d.make_current()
	
class PlayerNoise:
	var location:Vector3
	var intensity:NoiseLevel

	enum NoiseLevel{
		NULL, SOFT, AVERAGE, LOUD
	}
	
	static func create(loc:Vector3, intense:NoiseLevel):
		var new_noise: PlayerNoise = PlayerNoise.new()
		new_noise.location = loc
		new_noise.intensity = intense
		return new_noise
