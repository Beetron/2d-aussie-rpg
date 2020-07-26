extends KinematicBody2D

export var HP : int
export var Damage : int


func dealDamage(hitAmount):
	if($DamageImmunity.is_stopped()):
		HP = HP - hitAmount
		
		if(HP <= 0):
			died()
			return
			
		$DamageImmunity.start()
		#Play hit animation
	return

func died():
	queue_free()
	#Play death animation
	return
