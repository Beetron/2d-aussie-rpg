extends Node

var currentLevel
var levelList = []
var pauseActive = false

func _ready():
	initLevelList()
	var firstLevelResource = load(levelList.pop_front())
	var firstLevel = firstLevelResource.instance()
	add_child(firstLevel)
	currentLevel = firstLevel
	return
	
func initLevelList():
	levelList.push_back("res://scene/Level 1.tscn")
	levelList.push_back("res://scene/Level 2.tscn")
	levelList.push_back("res://scene/BossLevel.tscn")
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
	

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		if(!pauseActive):
			pause()
		else:
			unpause()
	return

func pause():
	get_tree().paused = true
	$PauseMenu/GUI.show()
	pauseActive = true
	return

func unpause():
	$PauseMenu/GUI.hide()
	get_tree().paused = false
	pauseActive = false
	return
