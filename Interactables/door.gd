extends Node3D

@onready var interactable: Interactable = $Interactable
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var enabled:bool
@export var open:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable.enabled = enabled
	if open:
		animation_player.play("door_open")

func interact():
	animation_player.play("door_open")
	pass
