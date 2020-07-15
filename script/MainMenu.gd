extends Control

signal load_game
signal load_options

func _ready():
	self.connect("load_game", get_parent(), "load_game")
	self.connect("load_options", get_parent(), "load_options")
	return

func _on_Start_Game_pressed():
	emit_signal("load_game")
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
