extends CanvasLayer

signal unpause_button_pressed

func _ready():
	self.connect("unpause_button_pressed", get_parent(), "unpause")
	return

func _on_Unpause_pressed():
	emit_signal("unpause_button_pressed")
	return
