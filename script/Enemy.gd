extends KinematicBody2D

class_name Enemy

export var hp : int
export var damage : int
export var speed : float
const WANDER_DISTANCE = 100.0
const ATTACK_RANGE = 250.0
const STRAFE_RANGE = 150.0
var path : PoolVector2Array
var rng = RandomNumberGenerator.new()
var movement_frozen : bool

onready var player = get_parent().get_node("Player")
onready var nav = get_parent().get_node("Navigation2D")

func _ready():
	rng.randomize()
	return

func take_damage(hit_amount):
	if($DamageImmunity.is_stopped()):
		hp = hp - hit_amount
		if(hp <= 0):
			died()
		$AnimatedSprite.modulate = Color(3, 0, 0, 1)
		$DamageImmunity.start()
		movement_frozen = true
	return

func died():
	pass

func _physics_process(_delta):
	pass
	
func check_in_attack_range() -> bool:
	if(player.position.distance_to(position) <= ATTACK_RANGE):
		return true
	return false
	
func move_to_player():
	path = nav.get_simple_path(position, player.position)
	
	var distance = position.distance_to(player.position)
	if(distance > 1):
		move_along_path(speed)
	return
	
func strafe_around_player():
	#Path to a certain distance near the player
	var spacer = position.direction_to(player.position) * STRAFE_RANGE
	path = nav.get_simple_path(position, player.position - spacer)
	var distance = position.distance_to(player.position - spacer)
	if(distance > 1):
		move_along_path(speed)
	return

func move_randomly():
	#var distance_to_move = speed / 4.0
	#move_along_path(distance_to_move)
	return
	
func move_along_path(distance_to_move):
	while distance_to_move > 0 and path.size() > 0:
		var distance_to_next_point = position.distance_to(path[0])
		move_and_slide(position.direction_to(path[0]) * distance_to_move)
		if(distance_to_move > distance_to_next_point):
			path.remove(0)
		distance_to_move -= distance_to_next_point
	return
	
func _on_DamageImmunity_timeout():
	$AnimatedSprite.modulate = Color(1, 1, 1, 1)
	movement_frozen = false
	return

#Pick a random direction to walk in
#Also randomly pick how long before we pick a new direction
func _on_NewRandomDirection_timeout():
	var rand_num = rng.randf_range(0,PI)
	var rand_position = polar2cartesian(WANDER_DISTANCE,rand_num) + position
	path = nav.get_simple_path(position, rand_position)
	$NewRandomDirection.wait_time = float(rng.randi_range(4,8))
	$NewRandomDirection.start()
	return
