extends Control

onready var is_debug = OS.is_debug_build()

func _process(_delta):
	if(is_debug):
		var label_text = "FPS: "
		label_text += Engine.get_frames_per_second() as String
		$"FPS Counter".text = label_text
	return
