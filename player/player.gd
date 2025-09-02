extends CharacterBody3D

class_name Player

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var pickup_prompt: RichTextLabel = $CanvasLayer/Control/PickupPrompt
@onready var pickups_probe: Area3D = $Neck/Head/Camera3D/PickupsProbe
@onready var interactables_probe: Area3D = $Neck/Head/Camera3D/InteractablesProbe
@onready var camera_3d: Camera3D = $Neck/Head/Camera3D
@onready var interactable_prompt: RichTextLabel = $"CanvasLayer/Control/Interactable Prompt"
@onready var notification: RichTextLabel = $CanvasLayer/Control/Notification
@onready var neck: Marker3D = $Neck
@onready var head: Marker3D = $Neck/Head
@onready var debug_label: Label = $"CanvasLayer/Control/Debug Label"
@onready var shape_cast_3d: ShapeCast3D = $ShapeCast3D


@export_category("🏃‍♀️ Movement 🏃‍♀️")
@export var SPEED = 5.0
@export var headbob_amp:float = 0.05
@export var headbob_freq:float = 0.05
@export var headbob_map:Noise
@export var crouch_height:float = 0.75
@export var stand_height:float = 1.5
@export var drouch_duration:float = 0.5
var last_pos:Vector3
var bob_val:float = 0
const JUMP_VELOCITY = 4.5
var mouse_move:Vector2 = Vector2.ZERO
@export var max_sprint = 3.0
var sprint = 1.0
@export var mouse_sensitivity:float

var interactables:Array[Area3D] = []
var pickups:Array[Area3D] = []
var notification_time:float = 0
@export var notification_time_max:float = 1

var holding_object:Variant
var crouch_tween:Tween

enum State{
	NULL, WALKING, CROUCH_WALKING
}

var state:State = State.WALKING

func _ready() -> void:
	Global.event_bus.connect(handle_global_events)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion :
		mouse_move += event.relative * mouse_sensitivity
	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("click"):
		mouse_move = Vector2.ZERO
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		

func _physics_process(delta: float) -> void:
	debug_label.text = str(mouse_move)
	bob_head()
	notification_time -= delta
	if notification.visible and notification_time < 0:
		notification.visible = false
	match(state):
		State.WALKING:
			walking_process(delta)
		State.CROUCH_WALKING:
			crouch_walking_process(delta)

func handle_interacts_and_pickups():
	if Input.is_action_just_pressed("e"):
		if pickups.size() > 0:
			pickup()
		elif interactables.size() > 0:
			activate()
	
	if pickups.size() > 0:
		pickup_prompt.visible = true
		interactable_prompt.visible = false
	elif interactables.size() > 0:
		pickup_prompt.visible = false
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
	if Input.is_action_just_pressed("shift"):
		sprint = max_sprint
	if Input.is_action_just_released("shift"):
		sprint = 1.0
	
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
func move():
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (camera_3d.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED * sprint
		velocity.z = direction.z * SPEED * sprint
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
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
	crouch_tween.tween_property(cap, "height",crouch_height,drouch_duration)
	
func stand():
	var obstructed:bool = false
	shape_cast_3d.force_shapecast_update()
	if shape_cast_3d.get_collision_count() > 0:
		return
	state = State.WALKING
	var cap = collision_shape_3d.shape as CapsuleShape3D
	if crouch_tween and crouch_tween.is_running():
		crouch_tween.kill()
	crouch_tween = create_tween()
	crouch_tween.set_ease(Tween.EASE_OUT)
	crouch_tween.tween_property(cap, "height",stand_height,drouch_duration)

func walking_process(delta:float):
	premove(delta)
	handle_interacts_and_pickups()
	mouse_look()
	move()
	
func crouch_walking_process(delta:float):
	premove(delta)
	sprint = 0.5
	handle_interacts_and_pickups()
	mouse_look()
	move()
func bob_head():
	head.position.y =  sin(bob_val*headbob_freq) * -headbob_amp

func mouse_look():
	camera_3d.rotation.y -= mouse_move.x
	camera_3d.rotation.x -= mouse_move.y
	camera_3d.rotation.x = clampf(camera_3d.rotation.x, -PI/3, PI/3)
	mouse_move = Vector2.ZERO

func activate():
	var interactable:Area3D
	interactables = interactables.filter(func(thing): return thing.enabled)
	if interactables.size() == 0:
		return
	if interactables.size() > 1:
		interactables.sort_custom(func(a:Node3D,b:Node3D):
			return interactables_probe.global_position.distance_squared_to(a.global_position) < interactables_probe.global_position.distance_squared_to(b.global_position)
		)
	interactable = interactables[0]
	if interactable.has_method("interact"):
		interactable.interact(self)
	else:
		push_error("Interactable didn't have interact: %S"%interactable)

func pickup():
	var pickup:Area3D
	pickups = pickups.filter(func(thing): return thing.enabled)
	if pickups.size() == 0:
		return
	if pickups.size() > 1:
		pickups.sort_custom(func(a:Node3D,b:Node3D):
			return pickups_probe.global_position.distance_squared_to(a.global_position) < pickups_probe.global_position.distance_squared_to(b.global_position)
		)
	pickup = pickups[0]
	if pickup.has_method("pickup"):
		pickup.pickup(self)
	else:
		push_error("Interactable didn't have interact: %S"%pickup)

func handle_global_events(type:Global.Bus_Type, data):
	match(type):
		Global.Bus_Type.PLAYER_NOTIFICATION:
			notification.text = "[center]" + data
			notification.visible = true
			notification_time = notification_time_max

func _on_interactables_probe_area_entered(area: Area3D) -> void:
	if !area.enabled: return
	interactables.append(area)

func _on_interactables_probe_area_exited(area: Area3D) -> void:
	if interactables.has(area):
		interactables.erase(area)
		
func _on_pickups_probe_area_entered(area: Area3D) -> void:
	if area.enabled:
		pickups.append(area)

func _on_pickups_probe_area_exited(area: Area3D) -> void:
	pickups.erase(area)
