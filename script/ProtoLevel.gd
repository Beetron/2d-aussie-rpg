extends Node2D

const ToadCorpse = preload("res://scene/ToadCorpse.tscn")
const ToadExplosionParticle = preload("res://scene/ExplosionParticle.tscn")

signal load_next_level


func _ready():
	self.connect("load_next_level", get_parent(), "load_next_level")
	return

func _process(_delta):
	#var path = $Navigation2D.get_simple_path($Explodetoad.position, $Player.position)
	#$PathDebug.points = path
	return

func playerThrowWeapon(Weapon, Player, eventPos, throwStrength):
	var weapon = Weapon.instance()
	add_child(weapon)
	weapon.init(Player)
	weapon.global_position = Player.global_position
	var throwImpulse = (eventPos - weapon.global_position).normalized() * throwStrength
	weapon.apply_central_impulse(throwImpulse)
	return

func toadDied(originalPosition):
	var toadCorpse = ToadCorpse.instance()
	toadCorpse.position = originalPosition
	add_child(toadCorpse)
	return

func toadParticles(originalPosition):
	var explosion = ToadExplosionParticle.instance()
	explosion.position = originalPosition
	explosion.one_shot = true
	add_child(explosion)
	return
