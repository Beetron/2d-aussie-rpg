extends RigidBody2D

var velocity = Vector2.ZERO

func _ready():
	$AnimationPlayer.play("spin")
	return
