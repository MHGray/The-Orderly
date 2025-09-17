extends Node

signal event_bus(bus:BusType, data)

enum BusType{ NULL, PLAYER_NOTIFICATION, ORDERLY_GET_PLAYER, PING_PLAYER, PLAYER_MADE_NOISE }

enum Key_Type{ NULL, GATE, CHAPEL_1, CHAPEL_2, CHAPEL_3, FLOPPY}
enum Tool_Type{ NULL, HAMMER, SCREWDRIVER }

func notify_player(message:String):
	event_bus.emit(BusType.PLAYER_NOTIFICATION, message)

func ping_player():
	event_bus.emit(BusType.PING_PLAYER, null)

func give_orderly_player(player:Player):
	event_bus.emit(BusType.ORDERLY_GET_PLAYER, player)
## 
