extends Enemy

var original_speed : float
signal toad_died(position)
signal toad_exploded(position)
var dying = false

func _ready():
	original_speed = speed
	self.connect("toad_died", get_parent(), "spawn_toad_corpse")
	self.connect("toad_exploded", get_parent(), "spawn_toad_particles")
	return

func _on_ExplosionZone_body_entered(body):
	if(body == player):
		trigger_explosion()
	return
	
func trigger_explosion():
	dying = true
	speed = 0
	$ExplodeTimer.start()
	$AnimatedSprite.play("Inflate")
	return

func _physics_process(_delta):
	if(movement_frozen == false):
		if(check_in_attack_range()):
			move_to_player()
		else:
			move_randomly()
	return

func _process(_delta):
	#Movement behaviour for players
	if(check_in_attack_range()):
		look_at(player.position)
		if(dying == false):
			$AnimatedSprite.play("Walk")
			if($AnimatedSprite.frame < 2):
				speed = 0
			else:
				speed = original_speed
	elif(path.size() > 0):
		look_at(path[0])
		if(dying == false):
			$AnimatedSprite.play("Walk")
	else:
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0
	return
	
func _on_ExplodeTimer_timeout():
	emit_signal("toad_exploded", position)
	$AnimatedSprite.play("Explode")
	get_tree().get_root().get_node("MasterScene/SoundManager/ToadExplode").play()
	$CollisionShape2D.set_deferred("disabled", true)
	if($ExplosionZone.overlaps_body(player)):
		player.call_deferred("take_damage",damage)
	$DeathTimer.start()
	return
	
func died():
	if(dying == false):
		trigger_explosion()
	return


func _on_DeathTimer_timeout():
	call_deferred("queue_free")
	emit_signal("toad_died", position)
	return

func take_damage(hit_amount):
	if($DamageImmunity.is_stopped()):
		get_tree().get_root().get_node("MasterScene/SoundManager/ToadDamaged").play()
		hp = hp - hit_amount
		if(hp <= 0):
			died()
		$AnimatedSprite.modulate = Color(3, 0, 0, 1)
		$DamageImmunity.start()
		movement_frozen = true
	return
