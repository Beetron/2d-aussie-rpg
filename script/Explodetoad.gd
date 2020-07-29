extends "res://script/Enemy.gd"



func _on_ExplosionZone_body_entered(body):
	if(body == player):
		triggerExplosion()
	return
	
func triggerExplosion():
	movementFrozen = true
	$ExplodeTimer.start()
	#Play explosion animation
	return



func _on_ExplodeTimer_timeout():
	if($ExplosionZone.overlaps_body(player)):
		player.takeDamage(damage)
	died()
	return
