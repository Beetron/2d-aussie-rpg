extends AnimatedSprite

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	frame = rng.randi_range(0,7)
	rotation = rng.randf_range(0, PI)
	return

func save():
	var save_dict = {
		"filename" : get_filename(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		}
	return save_dict
