extends KinematicBody2D

const UP = Vector2(0,-1)
const GRAVITY = 20
const SPEED = 200
const JUMP_HEIGHT = -600
var motion = Vector2()
var facingFlag = false #false is right, true is left

func moveRight():
	motion.x = SPEED
	facingFlag = false
	$Sprite.flip_h = false
	

func moveLeft():
	motion.x = -SPEED
	facingFlag = true
	$Sprite.flip_h = true

func _physics_process(delta):
	motion.y += GRAVITY

	#ground animations
	if is_on_floor():
		#run
		if Input.is_action_pressed("ui_right"):
			moveRight()
			$Sprite.play("run")
		elif Input.is_action_pressed("ui_left"):
			moveLeft()
			$Sprite.play("run")
			
		#jump
		elif Input.is_action_pressed("ui_up"):
			$Sprite.flip_h = facingFlag
			$Sprite.play("jumpAnticip")
			#motion.x = 0 
			
		elif Input.is_action_just_released("ui_up"):
			motion.y = JUMP_HEIGHT

		#idle
		else:
			motion.x = 0
			$Sprite.play("idle")

	#air animations
	if not is_on_floor():
		#jumping animation
		if  motion.y < 0:
			$Sprite.flip_h = facingFlag
			$Sprite.play("jump")
			if Input.is_action_pressed("ui_right"):
				moveRight()
			elif Input.is_action_pressed("ui_left"):
				moveLeft()
			
		#falling animation
		elif  motion.y >= 0:
			$Sprite.flip_h = facingFlag
			$Sprite.play("fall")
			if Input.is_action_pressed("ui_right"):
				moveRight()
			elif Input.is_action_pressed("ui_left"):
				moveLeft()
	
	motion = move_and_slide(motion, UP)
	pass
	

