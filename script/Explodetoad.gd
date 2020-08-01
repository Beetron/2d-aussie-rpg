extends "res://script/Enemy.gd"

var originalSpeed : float
signal toadDied(position)
signal toadParticles(position)
var dying = false

func _ready():
	originalSpeed = speed
	self.connect("toadDied", get_parent(), "toadDied")
	self.connect("toadParticles", get_parent(), "toadParticles")
	return

func _on_ExplosionZone_body_entered(body):
	if(body == player):
		triggerExplosion()
	return
	
func triggerExplosion():
	dying = true
	speed = 0
	$ExplodeTimer.start()
	$AnimatedSprite.play("Inflate")
	return

func _process(delta):
	#Movement behaviour for players
	if(checkInAttackRange()):
		look_at(player.position)
		if(dying == false):
			$AnimatedSprite.play("Walk")
			if($AnimatedSprite.frame < 2):
				speed = 0
			else:
				speed = originalSpeed
	elif(path.size() > 0):
		look_at(path[0])
		if(dying == false):
			$AnimatedSprite.play("Walk")
	else:
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0
	return
	
func _on_ExplodeTimer_timeout():
	emit_signal("toadParticles", position)
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
	emit_signal("toadDied", position)
	return
