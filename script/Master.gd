extends Node

const MainMenu = preload("res://scene/MainMenu.tscn")

var current_scene

func _ready():
	restore_options()
	load_main_menu()
	return
	
func remove_current_scene():
	if current_scene != null:
		remove_child(current_scene)
		current_scene.call_deferred("free")
	return
	
func load_main_menu():
	remove_current_scene()
	var menu = MainMenu.instance()
	add_child(menu)
	current_scene = menu
	return
	
func load_game():
	remove_current_scene()
	var game_resource = load("res://scene/Game.tscn")
	var game = game_resource.instance()
	add_child(game)
	current_scene = game
	game.load_next_level()
	return
	
func load_options():
	remove_current_scene()
	var option_resource = load("res://scene/Options.tscn")
	var option = option_resource.instance()
	add_child(option)
	current_scene = option
	return

func get_current_level():
	var game = get_node("Game")
	if !game:
		printerr("Error: Game Scene not found!")
	else:
		var current_level = game.current_level_path
		if !current_level:
			printerr("Error: Current level not found!")
		else:
			return current_level
	return null

func save_game():
	var save_game = File.new()
	save_game.open("user://larrikinquest.save", File.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("persist")
	save_nodes += get_tree().get_nodes_in_group("player")
	
	var game_instance = get_node("Game")
	for line in game_instance.last_save_state:
		save_game.store_line(line)
	
	var current_level = get_current_level()
	if !current_level:
		printerr("Save couldn't find current level.")
	else:
		save_game.store_line(to_json(get_current_level()))
		
	save_game.store_line(to_json(game_instance.last_save_coins))
	save_game.store_line(to_json(game_instance.coins))
	
	for node in save_nodes:
		if node.filename.empty():
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		var node_data = node.call("save")
		if(node_data != null):
			save_game.store_line(to_json(node_data))
	save_game.close()
	return

func restore_save():
	remove_current_scene()
	var game_resource = load("res://scene/Game.tscn")
	var game = game_resource.instance()
	add_child(game)
	current_scene = game
	
	var save_game = File.new()
	if not save_game.file_exists("user://larrikinquest.save"):
			return

	save_game.open("user://larrikinquest.save", File.READ)
	
	while save_game.get_position() < save_game.get_len():
		var line = save_game.get_line()
		if line.begins_with("\"res://scene/Level"):
			var level_path = parse_json(line)
			game.load_level_by_path(level_path)
			break
		else:
			game.last_save_state.append(line)
	
	game.last_save_coins = parse_json(save_game.get_line())
	game.coins = parse_json(save_game.get_line())
	game.update_coin_display()

	var save_nodes = get_tree().get_nodes_in_group("player")
	save_nodes += get_tree().get_nodes_in_group("persist")
	
	for i in save_nodes:
		i.queue_free()
	
	while save_game.get_position() < save_game.get_len():
		var node_data = parse_json(save_game.get_line())

		var new_object = load(node_data["filename"]).instance()
		get_node(node_data["parent"]).add_child(new_object)
		if node_data.has("pos_x") and node_data.has("pos_y"):
			new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])

		if node_data.has("saved_position_x") and node_data.has("saved_position_y"):
			new_object.saved_position = Vector2(node_data["saved_position_x"], node_data["saved_position_y"])
			
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y" or i == "saved_position_x" or i == "saved_position_y":
				continue
			new_object.set(i, node_data[i])

	#Update enemies player reference with new player node
	var enemies = get_tree().get_nodes_in_group("enemies")
	for i in enemies:
		i.call("get_player")

	var player_nodes = get_tree().get_nodes_in_group("player")
	var player = player_nodes.back()
	game.update_hp_bar(player.hp)

	if player.current_weapon == 0:
		player.equip_weapon("Boomerang")
	elif player.current_weapon == 1:
		player.equip_weapon("Knife")
	
	
	save_game.close()
	return

func save_and_quit():
	save_game()
	load_main_menu()
	return	
	
func restore_options():
	var saved_options = File.new()
	if not saved_options.file_exists("user://larrikinquestoptions.save"):
		return
	saved_options.open("user://larrikinquestoptions.save", File.READ)
	while saved_options.get_position() < saved_options.get_len():
		var saved_sfx_volume = parse_json(saved_options.get_line())
		var SFX_bus = AudioServer.get_bus_index("SFX")
		AudioServer.set_bus_volume_db(SFX_bus,saved_sfx_volume)
		OS.window_fullscreen = parse_json(saved_options.get_line())
		OS.window_borderless = parse_json(saved_options.get_line())
	saved_options.close()
	return
