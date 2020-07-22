extends Node2D

signal load_next_level

func _ready():
	self.connect("load_next_level", get_parent(), "load_next_level")
	return

func _process(delta):
	return

func playerThrowWeapon(Weapon, Player, eventPos, throwStrength):
	var weapon = Weapon.instance()
	add_child(weapon)
	weapon.init(Player)
	weapon.global_position = Player.global_position
	var throwImpulse = (eventPos - weapon.global_position).normalized() * throwStrength
	weapon.apply_central_impulse(throwImpulse)
	return
