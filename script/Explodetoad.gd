extends "res://script/Enemy.gd"

var originalSpeed : float
signal toadDied(position, rotation)
var dying = false

func _ready():
	originalSpeed = speed
	self.connect("toadDied", get_parent(), "toadDied")
	return

func _on_ExplosionZone_body_entered(body):
	if(body == player):
		triggerExplosion()
	return
	
func triggerExplosion():
	dying = true
	movementFrozen = true
	$ExplodeTimer.start()
	$AnimatedSprite.play("Inflate")
	return

func _process(delta):
	if(path.size() > 0):
		look_at(path[0])
	else:
		look_at(player.position)
	if($AnimatedSprite.frame < 2):
		speed = 0
	else:
		speed = originalSpeed
	return


func _on_ExplodeTimer_timeout():
	$AnimatedSprite.play("Explode")
	$CollisionShape2D.disabled = true
	if($ExplosionZone.overlaps_body(player)):
		player.takeDamage(damage)
	$DeathTimer.start()
	return
	
func died():
	if(dying == false):
		triggerExplosion()
	return


func _on_DeathTimer_timeout():
	queue_free()
	emit_signal("toadDied", position, rotation)
	return
