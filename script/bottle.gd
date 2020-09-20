extends Area2D

export var speed : float
var damage : int

func _ready():
	$AnimationPlayer.play("Spin")
	return

func _physics_process(delta):
	position += -transform.x * speed * delta
	return

func _on_Bottle_body_entered(body):
	if(body.is_in_group("player")):
		body.take_damage(damage)
	call_deferred("queue_free")
	return
