extends Node

signal event_bus(bus:Bus_Type, data)

enum Bus_Type{ NULL, PLAYER_NOTIFICATION }
enum Key_Type{ NULL, GATE }
enum Tool_Type{ NULL, HAMMER, SCREWDRIVER }

func notify_player(message:String):
	event_bus.emit(Bus_Type.PLAYER_NOTIFICATION, message)
