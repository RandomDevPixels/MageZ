extends CharacterBody2D


const SPEED = 300.0
const ACCELARATION = 300
const FRICTION = 800
const JUMP_VELOCITY = -350.0

@onready var animated_sprite_2d = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var double_jump = false

func _physics_process(delta):
	var direction = Input.get_axis("left", "right")
	
	#custom_function
	apply_gravity(delta)
	handle_jump()
	handle_movement(direction,delta)
	handle_char_animation(direction)
	
	
	move_and_slide()
	
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
func handle_jump():
	if is_on_floor(): 
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			double_jump = true
	elif not is_on_floor():
		#short Jump
		if Input.is_action_just_released("jump") and velocity.y < JUMP_VELOCITY / 2:
			velocity.y = JUMP_VELOCITY / 2
#		#double jump
		if Input.is_action_just_pressed("jump") and double_jump:
			velocity.y = JUMP_VELOCITY
			double_jump = false

func handle_movement(direction,delta):
	if direction == 1 and velocity.x >= 0:
		velocity.x = move_toward(velocity.x , SPEED * direction, ACCELARATION * delta)
	elif direction == -1 and velocity.x <= 0:
		velocity.x = move_toward(velocity.x , SPEED * direction, ACCELARATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

func handle_char_animation(direction):
	if direction != 0:
		animated_sprite_2d.flip_h = (direction < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

	if not is_on_floor():
		animated_sprite_2d.play("jump")
