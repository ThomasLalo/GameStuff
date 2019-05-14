extends KinematicBody2D

const UP = Vector2(0,-1)
const GRAVITY = 20
const SPEED = 200
const JUMP_HEIGHT = -600
const MAX_GRAVITY = 3000
var motion = Vector2()

# jump flag allows for one jump per button press
# true, means jump avaliable
var jumpFlag = true 

# counter to allow for implemetation of jumpAnticip
var jumpFrameCount = 0

func moveRight():
	motion.x += SPEED
	$Sprite.flip_h = false

func moveLeft():
	motion.x += -SPEED
	$Sprite.flip_h = true

func _physics_process(delta):
	
	# reset horizontal motion on each physics frame for tighter control
	motion.x = 0
	
	print(motion.y)
	
	# gravity is ALWAYS pulling character down
	if motion.y <= MAX_GRAVITY:
		motion.y += GRAVITY
	
	# running movement, animation, and facing direction
	if Input.is_action_pressed("ui_right"):
		moveRight()
		if is_on_floor():
			$Sprite.play("run")
	if Input.is_action_pressed("ui_left"):
		moveLeft()
		if is_on_floor():
			$Sprite.play("run")
	
	# idle animation when not moving and on ground
	if motion.x == 0 and is_on_floor() and jumpFrameCount == 0:
		$Sprite.play("idle")
		
	#jump
	if Input.is_action_just_pressed("ui_up") and is_on_floor() and jumpFlag and jumpFrameCount == 0:
		$Sprite.play("jumpAnticip")
		jumpFrameCount += 1
	
		# give time for jumpAnticip to run
	if jumpFrameCount >= 4:
		$Sprite.play("jump")
		motion.y = JUMP_HEIGHT
		jumpFlag = false
		jumpFrameCount = 0
	
	if jumpFrameCount > 0:
		jumpFrameCount += 1
	
	if Input.is_action_just_released("ui_up"):
		jumpFlag = true
	
	# if you are in the air and you've stopped pressing up,
	# immediately start to fall
	if not is_on_floor() and not Input.is_action_pressed("ui_up"):
		if motion.y < 0:
			motion.y = 0
			$Sprite.play("fall")
	
	# if you are in the air and going down
	if motion.y > 0 and not is_on_floor():
		$Sprite.play("fall")
		#jumpFlag = false
	
	# update character position based on input from above?
	motion = move_and_slide(motion, UP)
	