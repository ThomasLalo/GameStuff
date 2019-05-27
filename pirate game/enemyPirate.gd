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
const MAX_HANG_TIME = 50

# ray casting flags and management NPC SPECIFIC
onready var visionRay = get_node("VisionRay")
var visionRight = Vector2(64,0)
var visionLeft = Vector2(-64,0)
var visionRayCollider = ""
var wallIncoming = false

# enemy Patrolling counters and flags NPC SPECIFIC
var patrolMoveCount = 0
const FULL_MOVE_FRAMES = 208 # run the run animation loop 16 times - DOESN'T WORK
const HALF_MOVE_FRAMES = 104

var patrolIdleCount = 0
const FULL_IDLE_FRAMES = 132 # run the idle animation loop 4 times - DOESN'T WORK
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

func _ready():
	visionRay.set_enabled(true)

func moveRight():
	motion.x += SPEED
	$Sprite.flip_h = false
	visionRay.set_cast_to(visionRight)

func moveLeft():
	motion.x += -SPEED
	$Sprite.flip_h = true
	visionRay.set_cast_to(visionLeft)

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
	
	#raycasting management
	if visionRay.is_colliding():
		visionRayCollider = visionRay.get_collider().get_class()
	else:
		visionRayCollider = ""

	if visionRayCollider == "KinematicBody2D":
			print("Yes") #looking at player
	
	elif visionRayCollider == "TileMap":
		wallIncoming = true
		print(wallIncoming)

	else:
		wallIncoming = false
		print(wallIncoming)
		
	#jump initiated
	if wallIncoming and is_on_floor() and anticipFrameCount == 0:
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
	if not is_on_floor() and not wallIncoming and hangTimeCount == 0:
		hangTimeCount = 1 #this only starts the counter, runs only once per jump

	if hangTimeCount > 0:
		hangTimeCount += 1

	# if frames for jump stop has passed, then fall.
	if hangTimeCount >= MAX_HANG_TIME:
		if motion.y < 0:
			motion.y = 0
			$Sprite.play("fall")
			hangTimeCount = 0

	# reset in air frames while on floor
	if is_on_floor():
		hangTimeCount = 0
		inAirFrames = 0

	# if you are in the air and going down
	if motion.y > 0 and not is_on_floor():
		$Sprite.play("fall")
	
	# update character position based on input from above,
	# will move until a collision is detected
	motion = move_and_slide(motion, UP)