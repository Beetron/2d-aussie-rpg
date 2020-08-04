extends KinematicBody2D

enum Weapon {BOOMERANG, MAGICBOOMERANG}

const Boomerang = preload("res://scene/Boomerang.tscn")

signal weapon_thrown(weapon, player_position, mouse_position, throw_strength)

export var max_speed = 300
export var acceleration_magnitude = 2500
export var stop_friction = 0.85
export var friction = 0.95

export var current_weapon = Weapon
export var boomerang_attack_speed = 0.2
export var boomerang_throw_strength = 500
export var throw_strength = 0

export var hp : int

onready var state_machine = $AnimationTree.get("parameters/playback")
var last_direction = "Down"

#var screen_size # Size of the game window.
var velocity = Vector2.ZERO
var boomerang_thrown = false

# Called when the node enters the scene tree for the first time.
func _ready():
	equip_weapon(Weapon.BOOMERANG)
	self.connect("weapon_thrown", get_parent(), "spawn_boomerang")
	$AnimationTree.active = true
	return

func _process(delta):
	handle_movement(delta)
	return
	
func handle_movement(delta):
	var acceleration = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		acceleration.x += 1
	if Input.is_action_pressed("ui_left"):
		acceleration.x -= 1
	if Input.is_action_pressed("ui_down"):
		acceleration.y += 1
	if Input.is_action_pressed("ui_up"):
		acceleration.y -= 1
	if !(Input.is_action_pressed("ui_left") or
		   Input.is_action_pressed("ui_right") or
		   Input.is_action_pressed("ui_down") or
		   Input.is_action_pressed("ui_up")):
		velocity = velocity * stop_friction #Apply extra friction to slow to a stop with no actions
		state_machine.travel("Idle"+last_direction)
			
	if acceleration.x != 0:
		if acceleration.x > 0:
			state_machine.travel("Right")
			last_direction = "Right"
		else:
			state_machine.travel("Left")
			last_direction = "Left"
	elif acceleration.y != 0:
		if acceleration.y > 0:
			state_machine.travel("Down")
			last_direction = "Down"
		else:
			state_machine.travel("Up")
			last_direction = "Up"
	
	if acceleration.length() > 0:
		acceleration = acceleration.normalized() * acceleration_magnitude
	
	velocity += acceleration * delta #Apply acceleration
	velocity = velocity * friction #Apply friction

	#Avoid diagionals being faster	
	if velocity.length() > 0:
		velocity = velocity.normalized() * clamp(velocity.length(), -max_speed, max_speed)
	return
	
func attack(_event):
	if($AttackTimer.is_stopped()):
		$AttackTimer.start()
		if(!boomerang_thrown):
			emit_signal("weapon_thrown", current_weapon, position, get_global_mouse_position(), throw_strength)
			boomerang_thrown = true
	
func _input(event):
	if event.is_action_pressed("game_attack"):
		attack(event)
	return
	
func _physics_process(_delta):
	move_and_slide(velocity)
	return

func equip_weapon(new_weapon):
	match(new_weapon):
		Weapon.BOOMERANG:
			current_weapon = Boomerang
			$AttackTimer.wait_time = boomerang_attack_speed
			throw_strength = boomerang_throw_strength
	return

func boomerang_returned():
	boomerang_thrown = false
	return
	
func take_damage(hit_amount):
	if($DamageImmunity.is_stopped()):
		hp = hp - hit_amount
		print(hp)
		if(hp <= 0):
			#GameOver
			return
			
		$DamageImmunity.start()
		$Sprite.modulate = Color(3, 0, 0, 1)
		#Play hit animation
	return


func _on_DamageImmunity_timeout():
	$Sprite.modulate = Color(1, 1, 1, 1)
	return
