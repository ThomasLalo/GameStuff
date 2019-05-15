extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	respawn()
	$Player.show()

func respawn():
	$Player.position = $StartPosition.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_DeathBox_body_entered(body):
	if body.name == "Player":
		respawn()
