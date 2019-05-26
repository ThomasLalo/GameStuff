extends KinematicBody2D

const UP = Vector2(0,-1)
const GRAVITY = 20
const SPEED = 200
const JUMP_HEIGHT = -600
const MAX_GRAVITY = 3000
var motion = Vector2()

# counter to allow for implemetation of jumpAnticip
var jumpFrameCount = 0
const JUMP_PADDING = 4  # I changed this to a const for to make the code more readable for my own sake
var inAirFrames = 0

# counter to smooth out jumping
var endJumpFrameCount = 0
const END_JUMP_PADDING = 6

var inAirLeftCount = 0
var inAirRightCount = 0


# enemy Patrolling counters and flags
var patrolMoveCount = 0
const FULL_MOVE_FRAMES = 208 # run the run animation loop 16 times
const HALF_MOVE_FRAMES = 104

var patrolIdleCount = 0
const FULL_IDLE_FRAMES = 132 # run the idle animation loop 2 times
const HALF_IDLE_FRAMES = 66

var partolFlag = true
var patrolSequence = 0

###----------------------------------------------------------------###
# PATROLLING SEQUENCE
#
# 0, 1, and 2 are the initial movements
# 3, 4, 5, and 6 are in a loop, after step 3 will play after step 6
#
# 0 = 33 idle frames, half of the regular idle
# 1 = 104 right movement frames, half of regular movement
# 2 = 33 idle frames
#
# 3 = 208 left movement frames, regular movement amount
# 4 = 66 idle frames, regular idle amount
# 5 = 208 right movement frames
# 6 = 66 idle frames
###----------------------------------------------------------------###


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
	if partolFlag:
		match patrolSequence:
			0:
				if patrolIdleCount <= HALF_IDLE_FRAMES:
					$Sprite.play("idle")
					patrolIdleCount += 1
				else:
					patrolIdleCount = 0
					patrolSequence = 1
			1:
				if patrolMoveCount <= HALF_MOVE_FRAMES:
					moveRight()
					if is_on_floor():
						$Sprite.play("run")
					patrolMoveCount += 1
				else:
					patrolMoveCount = 0
					patrolSequence = 2

			2:
				if patrolIdleCount <= HALF_IDLE_FRAMES:
					$Sprite.play("idle")
					patrolIdleCount += 1
				else:
					patrolIdleCount = 0
					patrolSequence = 3

			3:
				if patrolMoveCount <= FULL_MOVE_FRAMES:
					moveLeft()
					if is_on_floor():
						$Sprite.play("run")
					patrolMoveCount += 1
				else:
					patrolMoveCount = 0
					patrolSequence = 4
			4:
				if patrolIdleCount <= FULL_IDLE_FRAMES:
					$Sprite.play("idle")
					patrolIdleCount += 1
				else:
					patrolIdleCount = 0
					patrolSequence = 5
			5:
				if patrolMoveCount <= FULL_MOVE_FRAMES:
					moveRight()
					if is_on_floor():
						$Sprite.play("run")
					patrolMoveCount += 1
				else:
					patrolMoveCount = 0
					patrolSequence = 6
			6:
				if patrolIdleCount <= FULL_IDLE_FRAMES:
					$Sprite.play("idle")
					patrolIdleCount += 1
				else:
					patrolIdleCount = 0
					patrolSequence = 3



		
	""" #jump initiated
	if Input.is_action_just_pressed("ui_up") and is_on_floor() and jumpFrameCount == 0:
		$Sprite.play("jumpAnticip")
		jumpFrameCount += 1
	
	# if frames for jumpAnticip has passed, jump with animation
	if jumpFrameCount >= JUMP_PADDING:
		$Sprite.play("jump")
		motion.y = JUMP_HEIGHT
		jumpFrameCount = 0
	
	if jumpFrameCount > 0:
		jumpFrameCount += 1
	
	if not is_on_floor():
		inAirFrames += 1
	
	# if you are in the air and you've stopped pressing up,
	# start to fall after frame count has passed
	if not is_on_floor() and Input.is_action_just_released("ui_up") and endJumpFrameCount == 0:
		endJumpFrameCount += 1
			
	# if frames for jump stop has passed, then fall.
	if endJumpFrameCount >= END_JUMP_PADDING or (inAirFrames > 5 and endJumpFrameCount > 3):
		if motion.y < 0:
			motion.y = 0
			$Sprite.play("fall")
			endJumpFrameCount = 0
			
	if endJumpFrameCount > 0:
		endJumpFrameCount += 1
	
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
		endJumpFrameCount = 0
		inAirFrames = 0
		inAirLeftCount = 0
		inAirRightCount = 0
	
	# if you are in the air and going down
	if motion.y > 0 and not is_on_floor():
		$Sprite.play("fall") """
	
	# update character position based on input from above,
	# will move until a collision is detected
	motion = move_and_slide(motion, UP)