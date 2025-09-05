extends StaticBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hiding_spot_left: Interactable = $LeftDoor/HidingSpotLeft

@onready var top_drawer: MeshInstance3D = $TopDrawer
@onready var top_drawer_interactable: Interactable = $TopDrawer/TopDrawerInteractable
@export var item_in_top_drawer:PickupModel
var top_drawer_open:bool = false

@onready var bottom_drawer: MeshInstance3D = $BottomDrawer
@onready var bottom_drawer_interactable: Interactable = $BottomDrawer/BottomDrawerInteractable
@export var item_in_bottom_drawer:PickupModel
var bottom_drawer_open:bool = false

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
			pass
		top_drawer_interactable:
			interact_top_drawer(player)
		bottom_drawer_interactable:
			interact_bottom_drawer(player)

func interact_top_drawer(player:Player):
	if top_drawer_open:
		animation_player.play_backwards("open_top_drawer")
	else:
		animation_player.play("open_top_drawer")
		if item_in_top_drawer:
			item_in_top_drawer.pickup.enabled = true
	top_drawer_open = !top_drawer_open

func interact_bottom_drawer(player:Player):
	if bottom_drawer_open:
		animation_player.play_backwards("open_bottom_drawer")
	else:
		animation_player.play("open_bottom_drawer")
		if item_in_bottom_drawer:
			item_in_bottom_drawer.pickup.enabled = true
	bottom_drawer_open = !bottom_drawer_open

func item_retrieved(side:Side):
	if side == Side.TOP:
		item_in_top_drawer = null
	elif side == Side.BOTTOM:
		item_in_bottom_drawer = null
		
