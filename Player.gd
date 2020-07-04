extends Area2D


export var maxSpeed = 300
export var accelerationMagnitude = 2500
export var stopFriction = 0.85
export var friction = 0.95

var screen_size # Size of the game window.
var velocity = Vector2(0,0)


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	return

func _process(delta):
	var acceleration = Vector2()
	if Input.is_action_pressed("ui_right"):
		acceleration.x += 1
		$AnimatedSprite.animation = "Right"
	if Input.is_action_pressed("ui_left"):
		acceleration.x -= 1
		$AnimatedSprite.animation = "Left"
	if Input.is_action_pressed("ui_down"):
		acceleration.y += 1
		$AnimatedSprite.animation = "Down"
	if Input.is_action_pressed("ui_up"):
		acceleration.y -= 1
		$AnimatedSprite.animation = "Up"
	if !(Input.is_action_pressed("ui_left") or
		   Input.is_action_pressed("ui_right") or
		   Input.is_action_pressed("ui_down") or
		   Input.is_action_pressed("ui_up")):
		velocity = velocity * stopFriction #Apply extra friction to slow to a stop with no actions
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 1 #Set animation to a "Neutral" position
			
	if acceleration.length() > 0:
		acceleration = acceleration.normalized() * accelerationMagnitude
		$AnimatedSprite.play()
	
	velocity += acceleration * delta #Apply acceleration
	velocity = velocity * friction #Apply friction

	#Avoid diagionals being faster	
	if velocity.length() > 0:
		velocity = velocity.normalized() * clamp(velocity.length(), -maxSpeed, maxSpeed)
	
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	
	return
