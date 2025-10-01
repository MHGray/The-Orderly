extends Node

signal event_bus(bus:BusType, data:Variant)

enum BusType{ NULL, PLAYER_NOTIFICATION, ORDERLY_GET_PLAYER, PING_PLAYER, PLAYER_MADE_NOISE, CONTAINERS_LOADED, CONTAINERS_PRIMED, VASE_SMASHED, PLAYER_IN_GARDEN }

enum Key_Type{ NULL, GATE, CHAPEL_1, CHAPEL_2, CHAPEL_3, }
enum Tool_Type{ NULL, HAMMER, SCREWDRIVER, FLOPPY, KEYCODE }

var mouse_sensitivity:float = 0.004
var beat_the_game:bool = false
var fullscreen:bool = false

func notify_player(message:String):
	event_bus.emit(BusType.PLAYER_NOTIFICATION, message)

func containers_loaded():
	event_bus.emit(BusType.CONTAINERS_LOADED, null)	

func containers_primed():
	event_bus.emit(BusType.CONTAINERS_PRIMED, null)

func vase_smashed():
	event_bus.emit(BusType.VASE_SMASHED, null)

func ping_player():
	event_bus.emit(BusType.PING_PLAYER, null)

func give_orderly_player(player:Player):
	event_bus.emit(BusType.ORDERLY_GET_PLAYER, player)

func player_in_garden(is_in_garden:bool):
	event_bus.emit(BusType.PLAYER_IN_GARDEN, is_in_garden)

func shortest_rotation_path(from_rotation: Vector3, to_rotation: Vector3) -> Vector3:
	var normalize_angle_diff:Callable = func(angle_diff: float) -> float:
		angle_diff = fmod(angle_diff + PI, TAU)
		if angle_diff < 0:
			angle_diff += TAU
		return angle_diff - PI

	var delta:Vector3 = to_rotation - from_rotation
	delta.x = normalize_angle_diff.call(delta.x)
	delta.y = normalize_angle_diff.call(delta.y)
	delta.z = normalize_angle_diff.call(delta.z)
	return from_rotation + delta
