extends Area2D

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	$Sprite.frame = rng.randi_range(0,3)
	return

func coins_picked_up():
	$Sparkle.emitting = true
	emit_signal("SpawnCoins", position)
	$Sprite.visible = false	
	$CollisionShape2D.set_deferred("disabled", true)
	$RemoveTimer.start()
	return

func _on_RemoveTimer_timeout():
	call_deferred("queue_free")
	return


func _on_Coins_body_entered(body):
	if(body.is_in_group("player")):
		coins_picked_up()
	return
