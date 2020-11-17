extends Enemy

signal bottle_thrown(position, rotation, damage)

var dying = false
var random_offset : Vector2

func _ready():
	self.connect("bottle_thrown", get_parent(), "spawn_thrown_bottle")
	return

func _physics_process(_delta):
	if(movement_frozen == false):
		if(check_in_attack_range()):
			strafe_around_player()
		else:
			move_randomly()
	return

func _process(delta):
	#Movement behaviour for players
	if dying == false:
		if check_in_attack_range():
				$AnimatedSprite.play("Walk")
				if($BottleTimer.is_stopped()):
					$BottleTimer.start()
		elif(path.size() > 0):
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
	var rotation = position.angle_to_point(player.position) 
	emit_signal("bottle_thrown", position, rotation, damage)
	get_tree().get_root().get_node("MasterScene/SoundManager/KangarooThrow").play()
	return
	
func died():
	if(dying == false):
		get_tree().get_root().get_node("MasterScene/SoundManager/KangarooDie").play()
		dying = true
		speed = 0
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0
		$CollisionShape2D.set_deferred("disabled", true)
		$AnimatedSprite.modulate = Color(0,1,1,1)
		$DespawnTimer.start()
	return


func _on_DespawnTimer_timeout():
	call_deferred("queue_free")
	return


func _on_BottleTimer_timeout():
	if check_in_attack_range() and dying == false:
		attack()
	return

func take_damage(hit_amount):
	if($DamageImmunity.is_stopped()):
		hp = hp - hit_amount
		get_tree().get_root().get_node("MasterScene/SoundManager/KangarooDamage").play()
		if(hp <= 0):
			died()
		$AnimatedSprite.modulate = Color(3, 0, 0, 1)
		$DamageImmunity.start()
		movement_frozen = true
	return
