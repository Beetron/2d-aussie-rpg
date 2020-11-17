extends KinematicBody2D

enum Weapon {BOOMERANG, KNIFE}

const Boomerang = preload("res://scene/Boomerang.tscn")

const TOP_RIGHT_CNR = -PI/4
const TOP_LEFT_CNR = -(3*PI)/4
const BOTTOM_RIGHT_CNR = PI/4
const BOTTOM_LEFT_CNR = (3*PI)/4

signal weapon_thrown(weapon, player_position, mouse_position, throw_strength)
signal player_hp_changed(amount)
signal player_died()
signal weapon_equipped(weapon)
signal interact_pressed()

export var max_speed = 300
export var acceleration_magnitude = 2500
export var stop_friction = 0.85
export var friction = 0.95

export var current_weapon = Weapon
export var boomerang_attack_speed = 0.2
export var boomerang_throw_strength = 600
export var throw_strength = 0

export var knife_attack_speed = 0.4
export var knife_damage = 2

export var hp : int
var original_HP : int

onready var state_machine = $AnimationTree.get("parameters/playback")
var last_direction = "Down"
var attacking = false
#var screen_size # Size of the game window.
var velocity = Vector2.ZERO
var boomerang_thrown = false
var boomerang_carried = false

var saved_position : Vector2
var position_reset = false
var coins : int

# Called when the node enters the scene tree for the first time.
func _ready():
	original_HP = hp
	self.connect("weapon_thrown", get_parent(), "spawn_boomerang")
	self.connect("player_hp_changed", get_parent(), "player_hp_changed")
	self.connect("weapon_equipped", get_parent(), "weapon_equipped")
	self.connect("interact_pressed", get_parent(), "interact")
	self.connect("player_died", get_parent(), "return_to_checkpoint")
	$AnimationTree.active = true
	
	equip_weapon("Knife")
	return

func _process(delta):
	handle_movement(delta)
	update()
	return
	
func handle_movement(delta):
	var acceleration = Vector2.ZERO
	if attacking == true:
		velocity = Vector2.ZERO
	else:
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
	
		#Avoid diagonals being faster	
		if velocity.length() > 0:
			velocity = velocity.normalized() * clamp(velocity.length(), -max_speed, max_speed)
	return
	
func throw_boomerang(_event):
	if(!boomerang_thrown):
		get_tree().get_root().get_node("MasterScene/SoundManager/ThrowBoomerang").play()
		emit_signal("weapon_thrown", Boomerang, position, get_global_mouse_position(), throw_strength)
		boomerang_thrown = true
	
func knife_strike(_event):
	get_tree().get_root().get_node("MasterScene/SoundManager/PlayerStab").play()
	#Attack in the direction of the mouse, cut up into 4 quadrants, also sets the last faced direction
	var angle = (get_global_mouse_position() - global_position).angle()
	if angle >= TOP_LEFT_CNR and angle < TOP_RIGHT_CNR:
		last_direction = "Up"
	elif angle >= TOP_RIGHT_CNR and angle < BOTTOM_RIGHT_CNR:
		last_direction = "Right"
	elif angle >= BOTTOM_RIGHT_CNR and angle < BOTTOM_LEFT_CNR:
		last_direction = "Down"
	else:
		last_direction = "Left"
	state_machine.travel("Attack"+last_direction)
	return
	
func _input(event):
	if event.is_action_pressed("game_attack"):
		if($AttackTimer.is_stopped()):
			$AttackTimer.start()
			attacking = true
			if(current_weapon == Weapon.BOOMERANG):
				throw_boomerang(event)
			elif(current_weapon == Weapon.KNIFE):
				knife_strike(event)
	elif event.is_action_pressed("weapon_swap") and boomerang_carried:
			get_tree().get_root().get_node("MasterScene/SoundManager/SwapWeapon").play()
			if(current_weapon == Weapon.BOOMERANG):
				equip_weapon("Knife")
			elif(current_weapon == Weapon.KNIFE):
				equip_weapon("Boomerang")
	elif event.is_action_pressed("interact"):
		emit_signal("interact_pressed")
	return
	
func _physics_process(_delta):
	if(position_reset):
		position = saved_position
		position_reset = false
		$Camera2D.align()
		last_direction = "Down"
	else:
		move_and_slide(velocity)
		
	if attacking == true:
		for i in $KnifeHitbox.get_overlapping_bodies():
			if i.is_in_group("enemies"):
				i.take_damage(knife_damage)
			elif i.is_in_group("breakable"):
				i.break_apart()
	return

func equip_weapon(new_weapon):
	match(new_weapon):
		"Boomerang":
			current_weapon = Weapon.BOOMERANG
			$AttackTimer.wait_time = boomerang_attack_speed
			throw_strength = boomerang_throw_strength
			emit_signal("weapon_equipped", "Boomerang")
		"Knife":
			current_weapon = Weapon.KNIFE
			$AttackTimer.wait_time = knife_attack_speed
			emit_signal("weapon_equipped", "Knife")
	return

func boomerang_returned():
	boomerang_thrown = false
	return
	
func restore_hp():
	hp = original_HP
	emit_signal("player_hp_changed", 3)
	return	

func take_damage(hit_amount):
	if($DamageImmunity.is_stopped()):
		hp = hp - hit_amount
		emit_signal("player_hp_changed", hp)
		$DamageImmunity.start()
		get_tree().get_root().get_node("MasterScene/SoundManager/PlayerDamage").play()
		if(hp <= 0):
			get_tree().get_root().get_node("MasterScene/SoundManager/PlayerDie").play()
			emit_signal("player_died")
			restore_hp()
			return
			
		$Sprite.modulate = Color(3, 0, 0, 1)
		$Camera2D.add_trauma((hit_amount as float / 5))
	return

func _on_DamageImmunity_timeout():
	$Sprite.modulate = Color(1, 1, 1, 1)
	return


func _on_AttackTimer_timeout():
	attacking = false
	return

func save_position(checkpoint_position):
	saved_position = checkpoint_position
	return

func restore_position():
	position_reset = true
	return

func save():
	var save_dict = {
		"filename" : get_filename(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"hp" : hp,
		"saved_position_x" : saved_position.x,
		"saved_position_y" : saved_position.y,
		"boomerang_carried" : boomerang_carried,
		"current_weapon" : current_weapon
		}
	return save_dict
