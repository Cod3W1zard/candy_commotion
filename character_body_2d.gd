extends CharacterBody2D


const SPEED = 225.0
const FRICTION = 36000
const ACCELERATION = 1200
const ANIMATION_DICT = {
	[1, -1]: "_up_right",
	[1, 0]: "_right",
	[1, 1]: "_down_right",
	[0, -1]: "_up",
	[0, 1]: "_down",
	[-1, -1]: "_up_left",
	[-1, 0]: "_left",
	[-1, 1]: "_down_left",
	}

@onready var sprite = $PlayerSprite
var prev_x = 0
var prev_y = -1
var facing_x = 0
var facing_y = -1
var state = "idle"
func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	
	
	if direction.x != 0:
		velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	if direction.y != 0:
		velocity.y = move_toward(velocity.y, direction.y * SPEED, ACCELERATION)
	else:
		velocity.y = move_toward(velocity.y, 0, FRICTION * delta)
		
	if prev_x != direction.x or prev_y != direction.y:
		if direction.x == 0 and direction.y == 0: 
			state = "idle"
		else:
			facing_x = int(round(direction.x))
			facing_y = int(round(direction.y))
			state = "walk"
	sprite.play(state + ANIMATION_DICT[[facing_x, facing_y]])
	prev_x = direction.x
	prev_y = direction.y
	move_and_slide()
