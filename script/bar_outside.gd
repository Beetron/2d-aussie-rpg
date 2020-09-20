extends Node2D

signal bar_entered

func _ready():
	self.connect("bar_entered", get_parent(), "go_inside_bar")
	return


func _on_Door_body_entered(body):
	if(body.is_in_group("player")):
		call_deferred("emit_signal","bar_entered")
	return
