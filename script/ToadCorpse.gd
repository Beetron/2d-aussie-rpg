extends AnimatedSprite

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	frame = rng.randi_range(0,7)
	rotation = rng.randf_range(0, PI)
	return
