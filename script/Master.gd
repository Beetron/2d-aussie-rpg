extends Node

const MainMenu = preload("res://scene/MainMenu.tscn")

var currentScene

func _ready():
	var menu = MainMenu.instance()
	add_child(menu)
	currentScene = menu
	return
	
func removeCurrentScene():
	remove_child(currentScene)
	currentScene.call_deferred("free")
	return
	
func load_game():
	removeCurrentScene()
	var gameResource = load("res://scene/Game.tscn")
	var game = gameResource.instance()
	add_child(game)
	currentScene = game
	return
	
func load_options():
	removeCurrentScene()
	var optionResource = load("res://scene/Options.tscn")
	var option = optionResource.instance()
	add_child(option)
	currentScene = option
	return
