extends RigidBody2D

export var speed = 600

var player
var boomerangReturning = false

func _ready():
	$AnimationPlayer.play("spin")
	return

func init(playerNode):
	player = playerNode
	return

func _integrate_forces(state):
	if(boomerangReturning):
		var velocity = (player.position - position).normalized() * speed
		set_linear_velocity(velocity)
	return


func _on_ReturnTimer_timeout():
	boomerangReturning = true
	return


func _on_CollisionTimer_timeout():
	set_collision_mask_bit(0, true)
	set_collision_layer_bit(0, true)
	return

func _on_Node2D_body_entered(body):
	if(body == player):
		body.boomerangReturned()
		queue_free()
		boomerangReturning = false
	return
