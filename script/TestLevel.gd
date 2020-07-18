extends Node2D

signal load_next_level

func _ready():
	self.connect("load_next_level", get_parent(), "load_next_level")
	return

func playerThrowWeapon(Weapon, gPlayerPosition, eventPos, throwStrength):
	var weapon = Weapon.instance()
	add_child(weapon)
	weapon.global_position = gPlayerPosition
	var throwImpulse = (eventPos - weapon.global_position).normalized() * throwStrength
	weapon.apply_central_impulse(throwImpulse)
	return
