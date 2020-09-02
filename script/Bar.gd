extends "res://script/level.gd"

var player_dialogue = false

signal left_bar

func _ready():
	self.connect("left_bar", get_parent(), "load_outside_scene")
	return

func interact():
	if(player_dialogue):
		print("Talking!")
	return


func _on_DialogueZone_body_entered(body):
	if(body.is_in_group("player")):
		player_dialogue = true
	return


func _on_DialogueZone_body_exited(body):
	if(body.is_in_group("player")):
		player_dialogue = false
	return

func _on_BarExit_body_entered(body):
	if(body.is_in_group("player")):
		call_deferred("emit_signal","left_bar")
	return
