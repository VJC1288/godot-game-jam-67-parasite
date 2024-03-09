extends CharacterBody3D


const Mind_Bullet_Scene = preload("res://Scenes/control_bullet.tscn")
const Slug_Standard_Collision = preload("res://Scenes/slug_standard_collision.tres")

@onready var cam_pivot = $CamPivot
@onready var camera_3d = $CamPivot/Camera3D
@onready var bullet_spawn_location = $BulletSpawnLocation
@onready var bullet_container = $BulletContainer
@onready var collision_shape_3d = $CollisionShape3D



enum PlayerStates {IDLE = 1, MOVING, JUMPING, FALLING, MINDCONTROLLING}
var currentPlayerState: PlayerStates
var currentMindControllee: Enemy

const SPEED = 5.0
const JUMP_VELOCITY = 5.0


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	currentPlayerState = PlayerStates.IDLE

func _input(event):
	
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	elif event is InputEventMouseMotion:
		cam_pivot.rotate_x(-event.relative.y * .005)
		rotate_y(-event.relative.x * .005)

		cam_pivot.rotation.x = clamp(cam_pivot.rotation.x, deg_to_rad(-50), deg_to_rad(10))
	
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	
	prints(currentPlayerState, velocity.y)
	
	match currentPlayerState:
		
		PlayerStates.IDLE:	
	
			# Add the gravity.
			if not is_on_floor():
				set_state(PlayerStates.FALLING)

			# Handle jump.
			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = JUMP_VELOCITY
				set_state(PlayerStates.JUMPING)
				
			accept_lateral_movement()
			try_shooting()

			move_and_slide()
			
		PlayerStates.MOVING:
			pass
			
		PlayerStates.JUMPING:
			if is_on_floor():
				set_state(PlayerStates.IDLE)
			
			accept_lateral_movement()
			try_shooting()
				
			velocity.y -= gravity * delta
			
			if velocity.y <= 0:
				set_state(PlayerStates.FALLING)
			
			move_and_slide()
			
		PlayerStates.FALLING:
			if is_on_floor():
				set_state(PlayerStates.IDLE)
			
			accept_lateral_movement()
			try_shooting()
			
			velocity.y -= gravity * delta * 1.5
			
			#Play Falling animation here
			
			move_and_slide()
		
		PlayerStates.MINDCONTROLLING:
			
			control_enemy_lateral_movement()
			position = currentMindControllee.slug_attach_point.global_position
			lose_control_of_enemy()
			
			


func set_state(new_state: PlayerStates):
	currentPlayerState = new_state


func control_enemy_lateral_movement():
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		currentMindControllee.velocity.x = direction.x * SPEED
		currentMindControllee.velocity.z = direction.z * SPEED
	else:
		currentMindControllee.velocity.x = move_toward(	currentMindControllee.velocity.x, 0, SPEED)
		currentMindControllee.velocity.z = move_toward(	currentMindControllee.velocity.z, 0, SPEED)
	
func accept_lateral_movement():
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
			

func try_shooting():
	if Input.is_action_just_pressed("action"):
		shoot()

func shoot():
	var mind_bullet = Mind_Bullet_Scene.instantiate()
	mind_bullet.position = bullet_spawn_location.global_position
	mind_bullet.transform.basis = bullet_spawn_location.global_transform.basis
	mind_bullet.hit_enemy.connect(take_control_of_enemy)
	get_parent().add_child(mind_bullet)
	
func take_control_of_enemy(controlled_enemy: Enemy):
	print("hit")
	set_state(PlayerStates.MINDCONTROLLING)
	currentMindControllee = controlled_enemy
	position = currentMindControllee.slug_attach_point.global_position
	currentMindControllee.take_control()

	

func lose_control_of_enemy():
	if Input.is_action_just_pressed("action"):
		currentMindControllee.lose_control()
		currentMindControllee = null
		velocity.y = JUMP_VELOCITY
		velocity.z += 20
		set_state(PlayerStates.JUMPING)
	 
