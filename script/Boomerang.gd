extends RigidBody2D

export var speed = 600
export var damage : int

var player

func _ready():
	$AnimationPlayer.play("spin")
	return

func init(playerNode):
	player = playerNode
	return

func _integrate_forces(_state):
	if($ReturnTimer.is_stopped()):
		var velocity = (player.position - position).normalized() * speed
		set_linear_velocity(velocity)
	return

func _on_CollisionTimer_timeout():
	#When boomerang returns, we want it to collide with the player again
	set_collision_mask_bit(1, true)
	return

func _on_Node2D_body_entered(body):
	if(body == player):
		body.boomerangReturned()
		call_deferred("queue_free")
	elif(body.is_in_group("enemies")):
		body.takeDamage(damage)
	elif(body.is_in_group("breakable")):
		body.breakApart()
	return
