extends CanvasLayer

signal unpause_button_pressed
signal savequit_button_pressed

func _ready():
	self.connect("unpause_button_pressed", get_parent(), "unpause")
	self.connect("savequit_button_pressed", get_parent(), "save_and_quit")
	return

func _on_Unpause_pressed():
	get_tree().get_root().get_node("MasterScene/SoundManager/MenuButtonClick").play()
	emit_signal("unpause_button_pressed")
	return


func _on_SaveAndQuit_pressed():
	get_tree().get_root().get_node("MasterScene/SoundManager/MenuButtonClick").play()
	emit_signal("savequit_button_pressed")
	return
