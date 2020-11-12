extends Node

signal save_and_quit

var current_level
var current_level_path
var outside_level_path
var level_list = []
var pause_active = false
var coins : int

var last_save_state = []
var last_save_coins : int

func _ready():
	self.connect("save_and_quit", get_parent(), "save_and_quit")
	init_level_list()
	return
	
func init_level_list():
	level_list.push_back("res://scene/Level 1.tscn")
	level_list.push_back("res://scene/Level 2.tscn")
	return

func remove_current_level():
	remove_child(current_level)
	current_level.call_deferred("free")
	return
	
func load_level_by_path(path):
	if current_level != null:
		remove_current_level()
	if !path:
		printerr("Level path is null.")
	else:
		current_level_path = path
		var next_level_resource = load(current_level_path)
		var next_level = next_level_resource.instance()
		add_child(next_level)
		current_level = next_level
	return	

func load_next_level():
	if current_level != null:
		remove_current_level()
	current_level_path = level_list.pop_front()
	var next_level_resource = load(current_level_path)
	var next_level = next_level_resource.instance()
	add_child(next_level)
	current_level = next_level
	return
	
func load_second_level():
	if current_level != null:
		remove_current_level()
	current_level_path = "res://scene/Level 2.tscn"
	var level_resource = load("res://scene/Level 2.tscn")
	var level = level_resource.instance()
	add_child(level)
	current_level = level
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
	hpbar.value = amount
	var hp_text = round(100 * (hpbar.value / hpbar.max_value))
	hp_percent.text = hp_text as String + "%" 
	return
	
func add_coins(amount):
	coins += amount
	update_coin_display()
	return
	
func update_coin_display():
	var coins_display = get_node("GameUI/PlayerUI/Cash")
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
	
func hide_dialogue_panel(finished_all_dialogue):
	$GameUI/Dialogue.visible = false
	if finished_all_dialogue:
		$GameUI/PlayerUI.visible = false
		if current_level != null:
			remove_current_level()
		var end_screen_resource = load("res://scene/End Screen.tscn")
		var scene = end_screen_resource.instance()
		add_child(scene)
		print(coins / 10)
		scene.set_beers(coins / 10)
	return

func save_checkpoint(checkpoint_position):
	last_save_state.clear()
	
	var player_nodes = get_tree().get_nodes_in_group("player")
	for i in player_nodes:
		if !i.has_method("save_position"):
			printerr("No save position function found")
		else:
			i.call("save_position", checkpoint_position)	
	last_save_coins = coins
	
	var save_nodes = get_tree().get_nodes_in_group("persist")
	for node in save_nodes:
			
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		
		var node_data = node.call("save")
		if(node_data != null):
			last_save_state.append(to_json(node_data))
	return
	
func restore_checkpoint():
	var save_nodes = get_tree().get_nodes_in_group("persist")
	for i in save_nodes:
		i.call_deferred("queue_free")
		
	var projectiles = get_tree().get_nodes_in_group("remove_on_load")
	for i in projectiles:
		i.call_deferred("queue_free")

	var player_nodes = get_tree().get_nodes_in_group("player")
	for i in player_nodes:
		if !i.has_method("restore_position"):
			printerr("No restore position function found")
		else:
			i.call("restore_position")
			i.boomerang_thrown = false	
	coins = last_save_coins
	update_coin_display()

	for n in last_save_state:
		var node_data = parse_json(n)
		
		var new_object = load(node_data["filename"]).instance()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
		
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	for i in enemies:
		i.call("get_player")
	$Transition/TransitionGUI.visible = true
	$Transition/TransitionTimer.start()
	get_tree().paused = true
	return
	
func _on_TransitionTimer_timeout():
	get_tree().paused = false
	$Transition/TransitionGUI.visible = false
	return
	
func save_and_quit():
	emit_signal("save_and_quit")
	return
