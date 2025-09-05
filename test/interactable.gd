extends Area3D

class_name Interactable

@export var node_with_interact_function:Node
@export var enabled = true
@export var custom_interact_message:String

func _ready() -> void:
	if node_with_interact_function == null:
		var parent = get_parent()
		if parent.has_method("interact"):
			node_with_interact_function = parent
		else:
			push_error("Interactable on parent with no interact\
			 and no node with interact set")
			
			
func interact(player:Player):
	if !enabled: return
	node_with_interact_function.interact(player,self)
