extends Control

signal options_concluded

var SFX_bus = AudioServer.get_bus_index("SFX")
var original_sfx_db : float

func _ready():
	self.connect("options_concluded", get_parent(), "load_main_menu")
	var sfx_slider = get_node("OptionContainer/SoundEffectsSlider")
	var db_value = AudioServer.get_bus_volume_db(SFX_bus)
	original_sfx_db = db_value
	var slider_value = (db_value + 60) * (sfx_slider.max_value / 60)
	sfx_slider.value = slider_value
	return


func _on_Accept_pressed():
	get_tree().get_root().get_node("MasterScene/SoundManager/MenuButtonClick").play()
	save_options()
	emit_signal("options_concluded")
	return


func _on_Cancel_pressed():
	get_tree().get_root().get_node("MasterScene/SoundManager/MenuButtonClick").play()
	AudioServer.set_bus_volume_db(SFX_bus,original_sfx_db)
	emit_signal("options_concluded")
	return


func _on_SoundEffectsSlider_value_changed(value):
	var max_value = $OptionContainer/SoundEffectsSlider.max_value
	var db_value = (value / (max_value / 60)) - 60
	AudioServer.set_bus_volume_db(SFX_bus,db_value)
	get_tree().get_root().get_node("MasterScene/SoundManager/MenuButtonClick").play()
	return


func save_options():
	var options = File.new()
	options.open("user://larrikinquestoptions.save", File.WRITE)
	options.store_line(to_json(AudioServer.get_bus_volume_db(SFX_bus)))
	options.close()
	return
