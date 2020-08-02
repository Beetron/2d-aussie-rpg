extends KinematicBody2D

enum Weapon {BOOMERANG, MAGICBOOMERANG}

const Boomerang = preload("res://scene/Boomerang.tscn")

signal throwWeapon(weapon, playerPos, eventPos, throwStrength)

export var maxSpeed = 300
export var accelerationMagnitude = 2500
export var stopFriction = 0.85
export var friction = 0.95

export var currentWeapon = Weapon
export var boomerangAttackSpeed = 0.2
export var boomerangThrowStrength = 500
export var throwStrength = 0

export var hp : int

var state_machine
var lastDirection = "Down"

#var screen_size # Size of the game window.
var velocity = Vector2.ZERO
var boomerangThrown = false

# Called when the node enters the scene tree for the first time.
func _ready():
	equipWeapon(Weapon.BOOMERANG)
	self.connect("throwWeapon", get_parent(), "playerThrowWeapon")
	$AnimationTree.active = true
	state_machine = $AnimationTree.get("parameters/playback")
	return

func _process(delta):
	handleMovement(delta)
	return
	
func handleMovement(delta):
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
		velocity = velocity * stopFriction #Apply extra friction to slow to a stop with no actions
		state_machine.travel("Idle"+lastDirection)
			
	if acceleration.x != 0:
		if acceleration.x > 0:
			state_machine.travel("Right")
			lastDirection = "Right"
		else:
			state_machine.travel("Left")
			lastDirection = "Left"
	elif acceleration.y != 0:
		if acceleration.y > 0:
			state_machine.travel("Down")
			lastDirection = "Down"
		else:
			state_machine.travel("Up")
			lastDirection = "Up"
	
	if acceleration.length() > 0:
		acceleration = acceleration.normalized() * accelerationMagnitude
	
	velocity += acceleration * delta #Apply acceleration
	velocity = velocity * friction #Apply friction

	#Avoid diagionals being faster	
	if velocity.length() > 0:
		velocity = velocity.normalized() * clamp(velocity.length(), -maxSpeed, maxSpeed)
	return
	
func attack(_event):
	if($AttackTimer.is_stopped()):
		$AttackTimer.start()
		if(!boomerangThrown):
			emit_signal("throwWeapon", currentWeapon, self, get_global_mouse_position(), throwStrength)
			boomerangThrown = true
	
func _input(event):
	if event.is_action_pressed("game_attack"):
		attack(event)
	return
	
func _physics_process(_delta):
	move_and_slide(velocity)
	return

func equipWeapon(newWeapon):
	match(newWeapon):
		Weapon.BOOMERANG:
			currentWeapon = Boomerang
			$AttackTimer.wait_time = boomerangAttackSpeed
			throwStrength = boomerangThrowStrength
	return

func boomerangReturned():
	boomerangThrown = false
	return
	
func takeDamage(hitAmount):
	if($DamageImmunity.is_stopped()):
		hp = hp - hitAmount
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
