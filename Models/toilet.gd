extends Node

@onready var animation_player: AnimationPlayer = $"."
@onready var toilet: LockableContainer = $".."
var contained_item:PickupModel
@export var open:bool
@onready var contained_item_location: Marker3D = $"../ContainedItemLocation"

func _ready() -> void:
	Global.event_bus.connect(handle_containers_primed)

func handle_containers_primed(bus:Global.BusType, _data):
	if bus == Global.BusType.CONTAINERS_PRIMED:
		setup()

func setup() -> void:
	if randi_range(0,1) == 1:
		open = true
		animation_player.play("open")
	else:
		animation_player.play("close")
		open = false
	if toilet.pickup:
		contained_item = toilet.pickup.model
	if contained_item:
		contained_item.freeze = true
		contained_item.pickup.enabled = open
		contained_item.pickup.picked_up.connect(item_retrieved)
		contained_item.reparent.call_deferred(contained_item_location,false)
		contained_item.position = Vector3.ZERO

func interact(_player:Player, _iactable:Interactable):
	if open and not animation_player.is_playing():
		animation_player.play("close")
		open = false
		if contained_item:
			contained_item.pickup.enabled = false
	elif not animation_player.is_playing():
		animation_player.play("open")
		open = true
		if contained_item:
			contained_item.pickup.enabled = true

func item_retrieved():
	contained_item = null

func init_pickup(_pickup:Pickup):
	pass
