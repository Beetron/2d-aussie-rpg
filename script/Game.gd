extends Node

var current_level
var level_list = []
var pause_active = false

func _ready():
	init_level_list()
	var first_level_resource = load(level_list.pop_front())
	var first_level = first_level_resource.instance()
	add_child(first_level)
	current_level = first_level
	return
	
func init_level_list():
	level_list.push_back("res://scene/Level 1.tscn")
	level_list.push_back("res://scene/Level 2.tscn")
	level_list.push_back("res://scene/BossLevel.tscn")
	return

func remove_current_level():
	remove_child(current_level)
	current_level.call_deferred("free")
	return
	
func load_next_level():
	remove_current_level()
	var next_level_resource = load(level_list.pop_front())
	var next_level = next_level_resource.instance()
	add_child(next_level)
	current_level = next_level
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
	coins_display.text = "$" + amount as String
	return
