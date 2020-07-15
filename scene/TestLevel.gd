extends Node2D

signal load_next_level

func _ready():
	self.connect("load_next_level", get_parent(), "load_next_level")
	return
