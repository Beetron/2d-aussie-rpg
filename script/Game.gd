extends Node

var current_level
var current_level_path
var outside_level_path
var level_list = []
var pause_active = false
var coins : int

func _ready():
	init_level_list()
	load_next_level()
	return
	
func init_level_list():
	level_list.push_back("res://scene/Level 1.tscn")
	level_list.push_back("res://scene/Level 2.tscn")
	return

func remove_current_level():
	remove_child(current_level)
	current_level.call_deferred("free")
	return
	
func load_next_level():
	if current_level != null:
		remove_current_level()
	current_level_path = level_list.pop_front()
	print(current_level_path)
	var next_level_resource = load(current_level_path)
	var next_level = next_level_resource.instance()
	add_child(next_level)
	current_level = next_level
	return
	
func load_bar_scene():
	outside_level_path = current_level_path
	remove_current_level()
	var bar_level_resource = load("res://scene/Bar.tscn")
	var bar_level = bar_level_resource.instance()
	add_child(bar_level)
	current_level = bar_level
	return
	
func load_outside_scene():
	if outside_level_path != null:
		remove_current_level()
		var outside_level_resource = load(outside_level_path)
		var outside_level = outside_level_resource.instance()
		add_child(outside_level)
		current_level = outside_level
	else:
		printerr("outside_level not found")
	return

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		if(!pause_active):
			pause()
		else:
			unpause()
	return

func pause():
	get_tree().paused = true
	$PauseMenu/GUI.show()
	pause_active = true
	return

func unpause():
	$PauseMenu/GUI.hide()
	get_tree().paused = false
	pause_active = false
	return

func update_hp_bar(amount):
	var hpbar = get_node("GameUI/PlayerUI/HealthBar")
	var hp_percent = get_node("GameUI/PlayerUI/HealthBar/HealthPercent")
	hpbar.value += amount
	var hp_text = round(100 * (hpbar.value / hpbar.max_value))
	hp_percent.text = hp_text as String + "%" 
	return
	
func update_coin_display(amount):
	var coins_display = get_node("GameUI/PlayerUI/Cash")
	coins += amount
	coins_display.text = "$" + coins as String
	return

func update_weapon_display(weapon):
	var weapon_display = get_node("GameUI/PlayerUI/WeaponDisplay/Weapon")
	match(weapon):
		"Boomerang":
			#Bad magic numbers to realign images how I like them
			weapon_display.texture = load("res://img/boomerang.png")
			weapon_display.rect_position = Vector2(16, 15.561)
			weapon_display.rect_rotation = 0
		"Knife":
			weapon_display.texture = load("res://img/knifeicon.png")
			weapon_display.rect_position = Vector2(12.683, 41.434)
			weapon_display.rect_rotation = -40.3
	return

func show_dialogue_panel():
	$GameUI/Dialogue.visible = true
	$GameUI/Dialogue.advance_dialogue()
	return
	
func hide_dialogue_panel():
	$GameUI/Dialogue.visible = false
	return
