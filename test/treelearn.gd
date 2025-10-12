extends Node


func _ready():
	for i in 100000:
		$"..".add_child.call_deferred(Node.new())
