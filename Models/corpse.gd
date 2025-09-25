extends Node

@onready var item_container: Marker3D = $"../ItemContainer"
@onready var corpse: LockableContainer = $".."

func _ready() -> void:
	Global.event_bus.connect(handle_containers_loaded)

func handle_containers_loaded(bus:Global.BusType, _data):
	if bus == Global.BusType.CONTAINERS_LOADED:
		setup()

func setup():
	if corpse.pickup:
		corpse.pickup.model.global_position = Vector3.ZERO
		corpse.pickup.model.global_rotation = Vector3.ZERO
		corpse.pickup.model.reparent(item_container,false)
		
