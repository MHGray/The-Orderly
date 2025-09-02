extends CharacterBody3D

class_name Player

@onready var interactables_probe: Area3D = $Neck/Head/Camera3D/InteractablesProbe
@onready var camera_3d: Camera3D = $Neck/Head/Camera3D
@onready var interactable_prompt: RichTextLabel = $"CanvasLayer/Control/Interactable Prompt"
@onready var notification: RichTextLabel = $CanvasLayer/Control/Notification
@onready var neck: Marker3D = $Neck
@onready var head: Marker3D = $Neck/Head

@export_category("🏃‍♀️ Movement 🏃‍♀️")
@export var SPEED = 5.0
@export var headbob_amp:float = 0.05
@export var headbob_freq:float = 0.05
@export var headbob_map:Noise
var last_pos:Vector3
var bob_val:float = 0
const JUMP_VELOCITY = 4.5
var mouse_move:Vector2 = Vector2.ZERO
@export var max_sprint = 3.0
var sprint = 1.0
@export var mouse_sensitivity:float

var interactables:Array[Area3D] = []
var notification_time:float = 0
@export var notification_time_max:float = 1

var holding_object:Variant

enum State{
	NULL, WALKING, 
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
	bob_head()
	notification_time -= delta
	if notification.visible and notification_time < 0:
		notification.visible = false
	match(state):
		State.WALKING:
			walking_process(delta)

func walking_process(delta:float):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("shift"):
		sprint = max_sprint
	
	if Input.is_action_just_released("shift"):
		sprint = 1.0
	
	if Input.is_action_just_pressed("e"):
		activate()
	
	if interactables.size() > 0:
		interactable_prompt.visible =true
	else:
		interactable_prompt.visible = false
	
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	mouse_look()
	
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

func _on_interactables_probe_area_entered(area: Area3D) -> void:
	if !area.enabled: return
	interactables.append(area)


func _on_interactables_probe_area_exited(area: Area3D) -> void:
	if interactables.has(area):
		interactables.erase(area)

func handle_global_events(type:Global.Bus_Type, data):
	match(type):
		Global.Bus_Type.PLAYER_NOTIFICATION:
			notification.text = "[center]" + data
			notification.visible = true
			notification_time = notification_time_max
