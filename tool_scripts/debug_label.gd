extends CanvasLayer

@export var orderly:Orderly

@onready var debuglabel: RichTextLabel = $VBoxContainer/debuglabel
@onready var debuglabel_2: RichTextLabel = $VBoxContainer/debuglabel2
@onready var debuglabel_3: RichTextLabel = $VBoxContainer/debuglabel3
@onready var debuglabel_4: RichTextLabel = $VBoxContainer/debuglabel4
var player:Player

func _process(_delta: float) -> void:
	var state = Orderly.State.find_key(orderly.state)
	var substate = Orderly.Substate.find_key(orderly.substate)
	debuglabel.text = "%s, %s. Chase Timer: %s" % [state,substate,orderly.chase_timer]
	debuglabel_2.text = str(orderly.nearby_doors, orderly.doors_to_close)
