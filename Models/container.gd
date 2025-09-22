extends Node3D

@export var interactable: Interactable
@export var animation_player: AnimationPlayer
@export var contained_item_location: Node3D
@export var contained_item:PickupModel
@export var open:bool
@export var openable:bool = false
@export var enable_pickup:bool = false
@onready var placeholder: Node3D = $placeholder

func _ready() -> void:
	placeholder.queue_free()
	if open and openable:
		animation_player.play("open")
	elif openable:
		animation_player.play_backwards("open")
	if contained_item:
		contained_item.pickup.enabled = enable_pickup
		contained_item.pickup.picked_up.connect(item_retrieved)
		contained_item.reparent.call_deferred(contained_item_location,false)
		contained_item.position = Vector3.ZERO

func interact(_player:Player, _iactable:Interactable):
	if open and openable:
		animation_player.play_backwards("open")
		open = false
		if contained_item:
			contained_item.pickup.enabled = false
	elif openable:
		animation_player.play("open")
		open = true
		if contained_item:
			contained_item.pickup.enabled = true
			
func item_retrieved():
	contained_item = null
