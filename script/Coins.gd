extends Area2D

var rng = RandomNumberGenerator.new()
export var amount = 10

signal coins_picked_up(amount)

func _ready():
	rng.randomize()
	$Sprite.frame = rng.randi_range(0,3)
	self.connect("coins_picked_up", get_parent(), "coins_picked_up")
	return

func coins_picked_up():
	$Sparkle.emitting = true
	emit_signal("coins_picked_up", amount)
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
