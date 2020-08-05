extends Enemy

signal spikes_fired(position, rotation, damage)

var dying = false
var random_offset : Vector2

func _ready():
	self.connect("spikes_fired", get_parent(), "spawn_lizard_spikes")
	random_offset.x = rng.randf_range(-20, 20)
	random_offset.y = rng.randf_range(-20, 20)
	return

func _process(delta):
	#Movement behaviour for players
	if dying == false:
		if check_in_attack_range():
				look_at(player.position + random_offset)
				$AnimatedSprite.play("Walk")
				if($SpikeTimer.is_stopped()):
					$SpikeTimer.start()
		elif(path.size() > 0):
			look_at(path[0])
			$AnimatedSprite.play("Walk")
		else:
			$AnimatedSprite.stop()
			$AnimatedSprite.frame = 0
	else:
		#Fade out over DespawnTimer seconds when dead
		var previous_color = $AnimatedSprite.modulate
		previous_color[3] = previous_color[3] - delta / $DespawnTimer.wait_time
		$AnimatedSprite.modulate = previous_color
	return

func attack():
	emit_signal("spikes_fired", position, rotation, damage)
	return


func _on_SpikeTimer_timeout():
	if check_in_attack_range() and dying == false:
		attack()
	return
	
	
func died():
	if(dying == false):
		dying = true
		speed = 0
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0
		$CollisionShape2D.set_deferred("disabled", true)
		$AnimatedSprite.modulate = Color(0,1,1,1)
		$AnimatedSprite.play("Death")
		$DespawnTimer.start()
	return


func _on_DespawnTimer_timeout():
	call_deferred("queue_free")
	return
