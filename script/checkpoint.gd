extends Node2D

signal activate

func _ready():
	self.connect("activate", get_parent(), "activate_checkpoint")
	return

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		get_tree().get_root().get_node("MasterScene/SoundManager/CheckpointReached").play()
		emit_signal("activate", position)
		if !body.has_method("restore_hp"):
			printerr("No restore_hp function found")
		else:
			body.call("restore_hp")	

	return
