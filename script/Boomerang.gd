extends RigidBody2D

var player

func _ready():
	$AnimationPlayer.play("spin")
	return

func init(playerNode):
	player = playerNode
	return

func _physics_process(delta):
	#print(player.global_position)
	
	#var test = (player.position - position).normalized() * 500 * delta
	#apply_central_impulse(test)
	var target = player.position + (player.velocity * delta)
	var test = (target - position) * 5
	set_applied_force(test)
	print(test)
	#print(test)
	return
