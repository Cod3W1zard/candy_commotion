extends CharacterBody2D


const SPEED = 300.0
const FRICTION = 36000
const ACCELERATION = 1200


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

	move_and_slide()
