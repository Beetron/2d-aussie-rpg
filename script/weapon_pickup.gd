extends Area2D

signal weapon_picked_up

func _ready():
	self.connect("weapon_picked_up", get_parent(), "weapon_picked_up")
	return
	
func _on_WeaponPickup_body_entered(body):
	if(body.is_in_group("player")):
		emit_signal("weapon_picked_up")
		call_deferred("queue_free")
	return

func save():
	var save_dict = {
		"filename" : get_filename(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		}
	return save_dict
