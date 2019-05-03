extends Area2D

func _physics_process(delta):
	
	# code to change world on collision with portal
	var bodies = get_overlapping_bodies()
	# print(bodies) # for debugging
	
	for body in bodies:
		if body.name == "KinematicBody2D":
			get_tree().change_scene("World.tscn")