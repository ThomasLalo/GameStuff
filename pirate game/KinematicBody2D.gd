extends KinematicBody2D

const UP = Vector2(0,-1)
const GRAVITY = 20
const SPEED = 200
const JUMP_HEIGHT = -600
const MAX_GRAVITY = 3000
var motion = Vector2()

# counter to allow for implemetation of jumpAnticip
var anticipFrameCount = 0
const ANTICIP_PADDING = 4 # I changed this to a const for to make the code more readable for my own sake
var inAirFrames = 0

# counter to smooth out jumping
var hangTimeCount = 0
const MAX_HANG_TIME = 6

var inAirLeftCount = 0
var inAirRightCount = 0


func moveRight():
	motion.x += SPEED
	$Sprite.flip_h = false

func moveLeft():
	motion.x += -SPEED
	$Sprite.flip_h = true

func _physics_process(delta):
	
	# reset horizontal motion on each physics frame for tighter control
	motion.x = 0
	
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
	if motion.x == 0 and is_on_floor() and anticipFrameCount == 0:
		$Sprite.play("idle")
		
	#jump initiated
	if Input.is_action_just_pressed("ui_up") and is_on_floor() and anticipFrameCount == 0:
		$Sprite.play("jumpAnticip")
		anticipFrameCount = 1 #this only starts the counter, runs only once per jump

	if anticipFrameCount > 0:
		anticipFrameCount += 1
		
	# if frames for jumpAnticip has passed, jump with animation
	if anticipFrameCount >= ANTICIP_PADDING:
		$Sprite.play("jump")
		motion.y = JUMP_HEIGHT
		anticipFrameCount = 0
	
	if not is_on_floor():
		inAirFrames += 1
	
	# if you are in the air and you've stopped pressing up,
	# start to fall after frame count has passed
	if not is_on_floor() and Input.is_action_just_released("ui_up") and hangTimeCount == 0:
		hangTimeCount = 1 #this only starts the counter, runs only once per jump

	if hangTimeCount > 0:
		hangTimeCount += 1

	# if frames for jump stop has passed, then fall.
	if hangTimeCount >= MAX_HANG_TIME or (inAirFrames > 5 and hangTimeCount > 3):
		if motion.y < 0:
			motion.y = 0
			$Sprite.play("fall")
			hangTimeCount = 0
		
	# pad left movement in air
	if not is_on_floor() and Input.is_action_just_released("ui_left") and inAirLeftCount == 0:
		inAirLeftCount = 1
	
	if inAirLeftCount > 0:
		inAirLeftCount += 1
	
	if inAirLeftCount < 5 and inAirLeftCount > 0:
		if not Input.is_action_pressed("ui_left"):
			moveLeft()
	
	# pad right movement in air
	if not is_on_floor() and Input.is_action_just_released("ui_right") and inAirRightCount == 0:
		inAirRightCount = 1
	
	if inAirRightCount > 0:
		inAirRightCount += 1
	
	if inAirRightCount < 5 and inAirRightCount > 0:
		if not Input.is_action_pressed("ui_right"):
			moveRight()
	
	# reset in air frames while on floor
	if is_on_floor():
		hangTimeCount = 0
		inAirFrames = 0
		inAirLeftCount = 0
		inAirRightCount = 0
	
	# if you are in the air and going down
	if motion.y > 0 and not is_on_floor():
		$Sprite.play("fall")
	
	# update character position based on input from above,
	# will move until a collision is detected
	motion = move_and_slide(motion, UP)