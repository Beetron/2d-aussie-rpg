extends Control

func _ready():
	get_tree().get_root().get_node("MasterScene/SoundManager/EndFanfare").play()
	return

func set_beers(new_value):
	var beers_count = new_value
	var text = "Larry proceeded to sink %s beers."
	$Beers.text = text % beers_count
	return


func _on_QuitGame_pressed():
	get_tree().quit()
	return
