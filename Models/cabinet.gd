extends StaticBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var top_drawer: MeshInstance3D = $TopDrawer
@onready var top_drawer_interactable: Interactable = $TopDrawer/TopDrawerInteractable
@export var item_in_top_drawer:PickupModel
var top_drawer_open:bool = false

@onready var bottom_drawer: MeshInstance3D = $BottomDrawer
@onready var bottom_drawer_interactable: Interactable = $BottomDrawer/BottomDrawerInteractable
@export var item_in_bottom_drawer:PickupModel
var bottom_drawer_open:bool = false

@onready var hiding_camera: Camera3D = $HidingCamera

@onready var left_door: MeshInstance3D = $LeftDoor
@onready var hiding_spot_left: Interactable = $HidingSpotLeft
var player_inside_left:bool 
var player_state_before_hide:Player.State

var player_inside_right:bool
@onready var hiding_spot_right: Interactable = $HidingSpotRight
@onready var right_door: MeshInstance3D = $RightDoor

enum Side{
	NULL, TOP, BOTTOM, LEFT, RIGHT
}

func _ready() -> void:
	if item_in_top_drawer:
		item_in_top_drawer.pickup.enabled = false
		item_in_top_drawer.pickup.picked_up.connect(item_retrieved.bind(Side.TOP))
		item_in_top_drawer.reparent.call_deferred(top_drawer,false)
		item_in_top_drawer.position = Vector3.ZERO
	if item_in_bottom_drawer:
		item_in_bottom_drawer.pickup.enabled = false
		item_in_bottom_drawer.pickup.picked_up.connect(item_retrieved.bind(Side.TOP))
		item_in_bottom_drawer.reparent.call_deferred(bottom_drawer,false)
		item_in_bottom_drawer.position = Vector3.ZERO

func interact(player:Player,interactable:Interactable):
	match(interactable):
		hiding_spot_left:
			interact_left_door(player)
		top_drawer_interactable:
			interact_top_drawer(player)
		bottom_drawer_interactable:
			interact_bottom_drawer(player)
		hiding_spot_right:
			interact_right_door(player)

func interact_top_drawer(_player:Player):
	if top_drawer_open:
		animation_player.play("close_top_drawer")
	else:
		animation_player.play("open_top_drawer")
		if item_in_top_drawer:
			item_in_top_drawer.pickup.enabled = true
	top_drawer_open = !top_drawer_open

func interact_bottom_drawer(_player:Player):
	if bottom_drawer_open:
		animation_player.play("close_bottom_drawer")
	else:
		animation_player.play("open_bottom_drawer")
		if item_in_bottom_drawer:
			item_in_bottom_drawer.pickup.enabled = true
	bottom_drawer_open = !bottom_drawer_open

func interact_left_door(player:Player):
	var anim:String
	if player_inside_left:
		anim = "hide_left_door" if player_state_before_hide == Player.State.WALKING else "hide_left_door_crouch"
	else:
		anim = "hide_left_door" if player.state == Player.State.WALKING else "hide_left_door_crouch"
	if player_inside_left:
		animation_player.play_backwards(anim)
		if !animation_player.animation_finished.is_connected(finish_hiding_left):
			animation_player.connect("animation_finished",finish_hiding_left.bind(player),CONNECT_ONE_SHOT)
	else:
		player_state_before_hide = player.state
		player.start_hiding(hiding_camera, interact.bind(player,hiding_spot_left))
		animation_player.play(anim)
		hiding_spot_left.custom_interact_message = "Press [E] or [SPACE] to leave"
		player_inside_left = true

func interact_right_door(player:Player):
	var anim:String
	if player_inside_right:
		anim = "hide_right_door" if player_state_before_hide == Player.State.WALKING else "hide_right_door_crouch"
	else:
		anim = "hide_right_door" if player.state == Player.State.WALKING else "hide_right_door_crouch"
	if player_inside_right:
		animation_player.play_backwards(anim)
		if !animation_player.animation_finished.is_connected(finish_hiding_right):
			animation_player.connect("animation_finished",finish_hiding_right.bind(player),CONNECT_ONE_SHOT)
	else:
		player_state_before_hide = player.state
		player.start_hiding(hiding_camera, interact.bind(player,hiding_spot_right))
		animation_player.play(anim)
		hiding_spot_right.custom_interact_message = "Press [E] or [SPACE] to leave"
		player_inside_right = true

func finish_hiding_left(_anim_name,player:Player):
	player_inside_left = false
	player.stop_hiding(player_state_before_hide)
	hiding_spot_left.custom_interact_message = "Press [E] or [Space] to hide"
	player.camera_3d.global_rotation = hiding_camera.global_rotation

func finish_hiding_right(_anim_name,player:Player):
	player_inside_right = false
	player.stop_hiding(player_state_before_hide)
	hiding_spot_right.custom_interact_message = "Press [E] or [Space] to hide"
	player.camera_3d.global_rotation = hiding_camera.global_rotation

func handle_animation_finished(_anim_name):
	pass

func item_retrieved(side:Side):
	if side == Side.TOP:
		item_in_top_drawer = null
	elif side == Side.BOTTOM:
		item_in_bottom_drawer = null
		
