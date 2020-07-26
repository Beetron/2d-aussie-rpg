extends CanvasLayer

signal unpause()

func _ready():
	self.connect("unpause", get_parent(), "unpause")
	return

func _on_Unpause_pressed():
	emit_signal("unpause")
	return
