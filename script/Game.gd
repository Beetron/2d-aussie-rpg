extends Node

var currentLevel
var levelList = []

func _ready():
	initLevelList()
	var firstLevelResource = load(levelList.pop_front())
	var firstLevel = firstLevelResource.instance()
	add_child(firstLevel)
	currentLevel = firstLevel
	return
	
func initLevelList():
	levelList.push_back("res://scene/TestLevel.tscn")
	return

func removeCurrentLevel():
	remove_child(currentLevel)
	currentLevel.call_deferred("free")
	return
	
func load_next_level():
	removeCurrentLevel()
	var nextLevelResource = load(levelList.pop_front())
	var nextLevel = nextLevelResource.instance()
	add_child(nextLevel)
	currentLevel = nextLevel
	return
