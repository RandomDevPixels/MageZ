extends CharacterBody2D

@export var movement_data : PlayerMovementData


@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer

var is_sliding_down_wall = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var sliding_gravity = gravity / 5
var can_double_jump = false


func _physics_process(delta):
	var direction = Input.get_axis("left", "right")
	
	#custom_function
	apply_gravity(delta)
	
	handle_jump()
	handle_double_jump()
	handle_wall_jump()
	handle_wall_slide(delta)
	
	handle_movement(direction,delta)
	handle_char_animation(direction)
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
	
	
func apply_gravity(delta):
	if not is_on_floor() and not is_sliding_down_wall :
		#print("gravityyy")
		velocity.y += gravity * delta
		
func handle_double_jump():
	if is_on_floor():
		can_double_jump = true
	elif not is_on_floor():
		if Input.is_action_just_pressed("jump") and can_double_jump:
			velocity.y = movement_data.jump_velocity * 0.8
			can_double_jump = false

func handle_wall_jump():
	if not is_on_wall(): return
	var wall_normal = get_wall_normal()
	
	if Input.is_action_pressed("right") and Input.is_action_just_pressed("jump") and is_on_wall_only() and wall_normal == Vector2.LEFT:
		velocity.x = wall_normal.x * movement_data.speed/2
		velocity.y = movement_data.jump_velocity
	if Input.is_action_pressed("left") and Input.is_action_just_pressed("jump") and is_on_wall_only()  and wall_normal == Vector2.RIGHT:
		velocity.x = wall_normal.x * movement_data.speed/2
		velocity.y = movement_data.jump_velocity

func handle_wall_slide(delta):
	#print(is_on_wall_only())
	if is_on_wall_only() and (Input.is_action_pressed("left") or Input.is_action_pressed("right")) and velocity.y > 0:
		print("sloooow")
		is_sliding_down_wall = true
		velocity.y += (sliding_gravity) * delta
		velocity.y = min(velocity.y, sliding_gravity)  
	else:
		is_sliding_down_wall = false

func handle_jump():
	if is_on_floor() or coyote_jump_timer.time_left > 0.0: 
		if Input.is_action_just_pressed("jump"):
			velocity.y = movement_data.jump_velocity
			coyote_jump_timer.stop()
	elif not is_on_floor():
		if Input.is_action_just_released("jump")  and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2

func handle_movement(direction,delta):
	if direction == 1 and velocity.x >= 0:
		velocity.x = move_toward(velocity.x , movement_data.speed * direction, movement_data.acceleration * delta)
	elif direction == -1 and velocity.x <= 0:
		velocity.x = move_toward(velocity.x , movement_data.speed * direction, movement_data.acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)

func handle_char_animation(direction):
	if direction != 0:
		animated_sprite_2d.flip_h = (direction < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

	if not is_on_floor():
		animated_sprite_2d.play("jump")
