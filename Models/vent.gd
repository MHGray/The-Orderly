@tool
extends Node3D

var opened:bool = false
@export_tool_button("play")var export_button:Callable = play
func interact(_player:Player, _iactable:Interactable):
	if opened: return
	
func play():
	($AnimationPlayer as AnimationPlayer).play("open")
