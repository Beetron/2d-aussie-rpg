extends Area2D

export var speed : float
var damage : int

func _physics_process(delta):
	position += transform.x * speed * delta
	return

func _on_Spikes_body_entered(body):
	if(body.is_in_group("player")):
		body.call_deferred("take_damage",damage)
	call_deferred("queue_free")
	return
