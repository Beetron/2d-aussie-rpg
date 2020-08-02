extends RigidBody2D

export var hp = 1

func breakApart():
	$LargeParticle.emitting = true
	$MediumParticle.emitting = true
	$SmallParticle.emitting = true
	#Spawn goodies
	$Sprite.visible = false	
	$CollisionShape2D.set_deferred("disabled", true)
	$RemoveTimer.start()
	return


func _on_RemoveTimer_timeout():
	queue_free()
	return
