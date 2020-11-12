extends Control

func set_beers(new_value):
	var beers_count = new_value
	var text = "Larry proceeded to sink %s beers."
	$Beers.text = text % beers_count
	return
