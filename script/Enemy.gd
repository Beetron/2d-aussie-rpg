extends KinematicBody2D

export var hp : int
export var damage : int
export var speed : float
const wanderDistance = 100.0
const attackRange = 250.0
var path : PoolVector2Array
var rng = RandomNumberGenerator.new()
var movementFrozen : bool

onready var player = get_parent().get_node("Player")
onready var nav = get_parent().get_node("Navigation2D")

func _ready():
	rng.randomize()
	return

func takeDamage(hitAmount):
	if($DamageImmunity.is_stopped()):
		hp = hp - hitAmount
		if(hp <= 0):
			died()
		$AnimatedSprite.modulate = Color(3, 0, 0, 1)
		$DamageImmunity.start()
		movementFrozen = true
		#Play hit animation
	return

func died():
	pass

func _physics_process(_delta):
	if(movementFrozen == false):
		if(checkInAttackRange()):
			moveToPlayer()
		else:
			moveRandomly()
	return
	
func checkInAttackRange() -> bool:
	if(player.position.distance_to(position) <= attackRange):
		return true
	return false
	
func moveToPlayer():
	path = nav.get_simple_path(position, player.position)
	
	var distance_to_move = speed
	while distance_to_move > 0 and path.size() > 0:
		var distance_to_next_point = position.distance_to(path[0])
		move_and_slide(position.direction_to(path[0]) * distance_to_move)
		if(distance_to_move > distance_to_next_point):
			path.remove(0)
		distance_to_move -= distance_to_next_point
	return

func moveRandomly():
	var distance_to_move = speed / 4.0
	while distance_to_move > 0 and path.size() > 0:
		var distance_to_next_point = position.distance_to(path[0])
		move_and_slide(position.direction_to(path[0]) * distance_to_move)
		if(distance_to_move > distance_to_next_point):
			path.remove(0)
		distance_to_move -= distance_to_next_point
	return
	
func _on_DamageImmunity_timeout():
	$AnimatedSprite.modulate = Color(1, 1, 1, 1)
	movementFrozen = false
	return

#Pick a random direction to walk in
#Also randomly pick how long before we pick a new direction
func _on_NewRandomDirection_timeout():
	var randNum = rng.randf_range(0,PI)
	var randPosition = polar2cartesian(wanderDistance,randNum) + position
	path = nav.get_simple_path(position, randPosition)
	$NewRandomDirection.wait_time = float(rng.randi_range(4,8))
	$NewRandomDirection.start()
	return
