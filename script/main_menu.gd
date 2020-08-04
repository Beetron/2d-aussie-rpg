extends Control

signal start_button_pressed
signal load_button_pressed

func _ready():
	self.connect("start_button_pressed", get_parent(), "load_game")
	self.connect("load_button_pressed", get_parent(), "load_options")
	return

func _on_Start_Game_pressed():
	emit_signal("start_button_pressed")
	return

func _on_Options_pressed():
	#emit_signal("load_options")
	return


func _on_Continue_pressed():
	pass # Replace with function body.


func _on_Load_Game_pressed():
	pass # Replace with function body.


func _on_Exit_pressed():
	get_tree().quit()
	return
