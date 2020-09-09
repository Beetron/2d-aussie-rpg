extends "res://script/level.gd"

var player_dialogue = false

signal left_bar
signal started_talking
signal stopped_talking

func _ready():
	self.connect("left_bar", get_parent(), "load_outside_scene")
	self.connect("started_talking", get_parent(), "show_dialogue_panel")
	self.connect("stopped_talking", get_parent(), "hide_dialogue_panel")
	return

func interact():
	if(player_dialogue):
		emit_signal("started_talking")
	return


func _on_DialogueZone_body_entered(body):
	if(body.is_in_group("player")):
		player_dialogue = true
	return


func _on_DialogueZone_body_exited(body):
	if(body.is_in_group("player")):
		player_dialogue = false
		emit_signal("stopped_talking")
	return

func _on_BarExit_body_entered(body):
	if(body.is_in_group("player")):
		call_deferred("emit_signal","left_bar")
	return
