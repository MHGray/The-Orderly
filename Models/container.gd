extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interactable: Interactable = $Interactable
@onready var contained_item_location: Marker3D = $ContainedItemLocation

@export var contained_item:PickupModel
@export var open:bool

func _ready() -> void:
	if open:
		animation_player.play("open")
	else:
		animation_player.play_backwards("open")
	if contained_item:
		contained_item.pickup.enabled = false
		contained_item.pickup.picked_up.connect(item_retrieved)
		contained_item.reparent.call_deferred(contained_item_location,false)
		contained_item.position = Vector3.ZERO

func interact(_player:Player, _iactable:Interactable):
	if open:
		animation_player.play_backwards("open")
		open = false
		if contained_item:
			contained_item.pickup.enabled = false
	else:
		animation_player.play("open")
		open = true
		if contained_item:
			contained_item.pickup.enabled = true
			
func item_retrieved():
	contained_item = null
