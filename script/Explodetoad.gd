extends "res://script/Enemy.gd"

var originalSpeed : float

func _ready():
	originalSpeed = speed
	return

func _on_ExplosionZone_body_entered(body):
	if(body == player):
		triggerExplosion()
	return
	
func triggerExplosion():
	movementFrozen = true
	$ExplodeTimer.start()
	#Play explosion animation
	return

func _process(delta):
	if(path.size() > 0):
		look_at(path[0])
	if($AnimatedSprite.frame < 2):
		speed = 0
	else:
		speed = originalSpeed
	return


func _on_ExplodeTimer_timeout():
	if($ExplosionZone.overlaps_body(player)):
		player.takeDamage(damage)
	died()
	return
