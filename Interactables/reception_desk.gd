extends StaticBody3D

@onready var right_interactable: Interactable = $RightDrawer/Interactable
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var right_drawer: MeshInstance3D = $RightDrawer
@onready var left_drawer: MeshInstance3D = $LeftDrawer

@export var item_in_left_drawer:PickupModel
@export var item_in_right_drawer:PickupModel

var left_drawer_open:bool = false
var right_drawer_open:bool = false

enum Side{
	NULL, LEFT, RIGHT
}

func _ready() -> void:
	if item_in_left_drawer:
		if item_in_left_drawer:
			item_in_left_drawer.pickup.enabled = false
			item_in_left_drawer.pickup.picked_up.connect(item_retrieved.bind(Side.LEFT))
		item_in_left_drawer.reparent.call_deferred(left_drawer,false)
		item_in_left_drawer.position = Vector3.ZERO
	if item_in_right_drawer:
		if item_in_right_drawer:
			item_in_right_drawer.pickup.enabled = false
			item_in_right_drawer.pickup.picked_up.connect(item_retrieved.bind(Side.RIGHT))
		item_in_right_drawer.reparent.call_deferred(right_drawer,false)
		item_in_right_drawer.position = Vector3.ZERO

func interact(player:Player,interact_area:Interactable):
	if interact_area == right_interactable:
		if right_drawer_open:
			animation_player.play_backwards("open_right_drawer")
			right_drawer_open = false
		else:
			animation_player.play("open_right_drawer")
			right_drawer_open = true
			if item_in_right_drawer:
				item_in_right_drawer.pickup.enabled = true
	else:
		if left_drawer_open:
			animation_player.play_backwards("open_left_drawer")
			left_drawer_open = false
		else:
			animation_player.play("open_left_drawer")
			left_drawer_open = true
			if item_in_left_drawer:
				item_in_left_drawer.pickup.enabled = true

func item_retrieved(side:Side):
	if side == Side.LEFT:
		item_in_left_drawer = null
	elif side == Side.RIGHT:
		item_in_right_drawer = null
		
