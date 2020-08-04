extends RigidBody2D

export var hp = 1
signal SpawnCoins(position)
var particlesShowing = false

func _ready():
	self.connect("SpawnCoins", get_parent(), "spawnCoins")
	return

func breakApart():
	$LargeParticle.emitting = true
	$MediumParticle.emitting = true
	$SmallParticle.emitting = true
	particlesShowing = true
	emit_signal("SpawnCoins", position)
	$Sprite.visible = false	
	$CollisionShape2D.set_deferred("disabled", true)
	$RemoveTimer.start()
	return

func _process(delta):
	if(particlesShowing):
		#Fade out particles from 1.0 alpha to 0 after they spawn
		var previousColor = $LargeParticle.modulate
		previousColor[3] = previousColor[3] - delta / $LargeParticle.lifetime
		$LargeParticle.modulate = previousColor
		$MediumParticle.modulate = previousColor
		$SmallParticle.modulate = previousColor
	return

func _on_RemoveTimer_timeout():
	call_deferred("queue_free")
	return
