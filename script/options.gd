extends Control

signal options_concluded

var SFX_bus = AudioServer.get_bus_index("SFX")
var original_sfx_db : float
var original_fullscreen : bool
var original_borderless : bool

func _ready():
	self.connect("options_concluded", get_parent(), "load_main_menu")
	
	#Set sfx slider initial value
	var sfx_slider = get_node("OptionsContainer/SFXContainer/SoundEffectsSlider")
	var db_value = AudioServer.get_bus_volume_db(SFX_bus)
	original_sfx_db = db_value
	var slider_value = (db_value + 60) * (sfx_slider.max_value / 60)
	sfx_slider.value = slider_value
	
	#Set fullscreen initial value
	original_fullscreen = OS.window_fullscreen
	var fullscreen_checkbox = get_node("OptionsContainer/FullscreenContainer/FullscreenCheckbox")
	fullscreen_checkbox.pressed = OS.window_fullscreen
	#Set borderless initial value
	original_borderless = OS.window_borderless
	var borderless_checkbox = get_node("OptionsContainer/BorderlessContainer/BorderlessCheckbox")
	borderless_checkbox.pressed = OS.window_borderless
	return


func _on_Accept_pressed():
	get_tree().get_root().get_node("MasterScene/SoundManager/MenuButtonClick").play()
	save_options()
	emit_signal("options_concluded")
	return


func _on_Cancel_pressed():
	get_tree().get_root().get_node("MasterScene/SoundManager/MenuButtonClick").play()
	AudioServer.set_bus_volume_db(SFX_bus,original_sfx_db)
	OS.window_fullscreen = original_fullscreen
	OS.window_borderless = original_borderless 
	emit_signal("options_concluded")
	return


func _on_SoundEffectsSlider_value_changed(value):
	var max_value = $OptionsContainer/SFXContainer/SoundEffectsSlider.max_value
	var db_value = (value / (max_value / 60)) - 60
	AudioServer.set_bus_volume_db(SFX_bus,db_value)
	get_tree().get_root().get_node("MasterScene/SoundManager/MenuButtonClick").play()
	return


func save_options():
	var options = File.new()
	options.open("user://larrikinquestoptions.save", File.WRITE)
	options.store_line(to_json(AudioServer.get_bus_volume_db(SFX_bus)))
	options.store_line(to_json(OS.window_fullscreen))
	options.store_line(to_json(OS.window_borderless))
	options.close()
	return


func _on_FullscreenCheckbox_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	return

func _on_BorderlessCheckbox_toggled(button_pressed):
	OS.window_borderless = button_pressed
	return
