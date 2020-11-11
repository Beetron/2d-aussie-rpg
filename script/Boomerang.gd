extends KinematicBody2D

export var speed = 600
export var damage : int

var velocity : Vector2

var player : Node2D

func _ready():
	get_player()
	$AnimationPlayer.play("spin")
	return
	
func get_player():
	var players = get_tree().get_nodes_in_group("player")
	player = players.back()
	return

func _physics_process(delta):
	if($ReturnTimer.is_stopped()):
		velocity = (player.position - position).normalized() * speed
	move_and_slide(velocity)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("player"):
			collision.collider.boomerang_returned()
			call_deferred("queue_free")
		elif(collision.collider.is_in_group("enemies")):
			collision.collider.take_damage(damage)
		elif(collision.collider.is_in_group("breakable")):
			collision.collider.break_apart()
	return

func _on_CollisionTimer_timeout():
	#When boomerang returns, we want it to collide with the player again
	set_collision_mask_bit(1, true)
	#Disable collisions with walls on the way back
	set_collision_mask_bit(0, false)
	return
