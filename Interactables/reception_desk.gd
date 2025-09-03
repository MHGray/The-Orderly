extends StaticBody3D

@onready var right_interactable: Interactable = $RightDrawer/Interactable
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var left_drawer_open:bool = false
var right_drawer_open:bool = false

func interact(player:Player,interact_area:Interactable):
	if interact_area == right_interactable:
		if right_drawer_open:
			animation_player.play_backwards("open_right_drawer")
			right_drawer_open = false
		else:
			animation_player.play("open_right_drawer")
			right_drawer_open = true
	else:
		if left_drawer_open:
			animation_player.play_backwards("open_left_drawer")
			left_drawer_open = false
		else:
			animation_player.play("open_left_drawer")
			left_drawer_open = true
