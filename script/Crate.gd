extends RigidBody2D

export var hp = 1
signal crate_broken(position)
var particles_showing = false

func _ready():
	self.connect("crate_broken", get_parent(), "spawn_coins")
	return

func break_apart():
	$LargeParticle.emitting = true
	$MediumParticle.emitting = true
	$SmallParticle.emitting = true
	particles_showing = true
	emit_signal("crate_broken", position)
	$Sprite.visible = false	
	$CollisionShape2D.set_deferred("disabled", true)
	$RemoveTimer.start()
	return

func _process(delta):
	if(particles_showing):
		#Fade out particles from 1.0 alpha to 0 after they spawn
		var previous_color = $LargeParticle.modulate
		previous_color[3] = previous_color[3] - delta / $LargeParticle.lifetime
		$LargeParticle.modulate = previous_color
		$MediumParticle.modulate = previous_color
		$SmallParticle.modulate = previous_color
	return

func _on_RemoveTimer_timeout():
	call_deferred("queue_free")
	return

func save():
	if $RemoveTimer.is_stopped():
		var save_dict = {
			"filename" : get_filename(),
			"parent" : get_parent().get_path(),
			"pos_x" : position.x,
			"pos_y" : position.y,
			"hp" : hp
			}
		return save_dict
	return null
