extends Control

signal start_button_pressed
signal load_button_pressed
signal continue_button_pressed

func _ready():
	self.connect("start_button_pressed", get_parent(), "load_game")
	self.connect("load_button_pressed", get_parent(), "load_options")
	self.connect("continue_button_pressed", get_parent(), "restore_save")
	
	var save_game = File.new()
	if save_game.file_exists("user://larrikinquest.save"):
		$MainMenuButtons/Continue.disabled = false
	save_game.close()
	return

func _on_Start_Game_pressed():
	emit_signal("start_button_pressed")
	return

func _on_Options_pressed():
	#emit_signal("load_options")
	return


func _on_Continue_pressed():
	emit_signal("continue_button_pressed")
	return


func _on_Exit_pressed():
	get_tree().quit()
	return
