extends KinematicBody2D

const UP = Vector2(0,-1)
var motion = Vector2()
var rightRunTimer = 0
var leftRunTimer = 0
var jumpFlag = true

func _physics_process(delta):
	motion.y += 20
	
	#move
	if Input.is_action_pressed("ui_right") and rightRunTimer == 0:
		motion.x = 300
		if leftRunTimer > 0:
			leftRunTimer -= 1 
	elif Input.is_action_pressed("ui_left") and leftRunTimer == 0:
		motion.x = -300 
		if rightRunTimer > 0:
			rightRunTimer -= 1
	
	#run
	elif Input.is_action_pressed("ui_right") and rightRunTimer > 1:
		motion.x = 600
		rightRunTimer = 2
		if leftRunTimer > 0:
			leftRunTimer -= 1 
	elif Input.is_action_pressed("ui_left") and leftRunTimer > 1:
		motion.x = -600
		leftRunTimer = 2
		if rightRunTimer > 0:
			rightRunTimer -= 1 
	
	#idle
	else:
		motion.x = 0
		if leftRunTimer > 0:
			leftRunTimer -= 1 
		if rightRunTimer > 0:
			rightRunTimer -= 1 

	#timer management
	if Input.is_action_just_released("ui_right") and rightRunTimer == 0:
		rightRunTimer = 10
	if Input.is_action_just_released("ui_left") and leftRunTimer == 0:
		leftRunTimer = 10
		
	#jump
	if is_on_floor():
		jumpFlag = true
		if Input.is_action_just_pressed("ui_up"):
			motion.y = -600
		
	
	#double jump
	if not is_on_floor():
		if Input.is_action_just_pressed("ui_up") and jumpFlag == true:
			motion.y = -600
			jumpFlag = false
	
	#updates movement in frame, as well as reseting gravity
	motion = move_and_slide(motion, UP)
	pass