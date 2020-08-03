extends Area2D

signal load_next_level

func _ready():
	self.connect("load_next_level", get_parent(), "LoadNextLevel")
	return

func _on_LevelGate_body_entered(body):
	if(body.is_in_group("player")):
		call_deferred("emit_signal", "load_next_level")
	return
