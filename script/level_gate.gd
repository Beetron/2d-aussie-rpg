extends Area2D

signal level_gate_entered

func _ready():
	self.connect("level_gate_entered", get_parent(), "end_of_level_reached")
	return

func _on_LevelGate_body_entered(body):
	if(body.is_in_group("player")):
		call_deferred("emit_signal", "level_gate_entered")
	return
