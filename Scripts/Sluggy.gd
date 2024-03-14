extends CharacterBody3D

class_name Player

signal player_died

const Mind_Bullet_Scene = preload("res://Scenes/control_bullet.tscn")


@onready var cam_pivot = $CamPivot
@onready var camera_3d = $CamPivot/Camera3D
@onready var bullet_spawn_location = $BulletSpawnLocation
@onready var bullet_container = $BulletContainer
@onready var collision_shape_3d = $CollisionShape3D
@onready var health_component = $HealthComponent
@onready var animation_player = $Slug/AnimationPlayer
@onready var death_label = %DeathLabel


enum PlayerStates {IDLE = 1, MOVING, JUMPING, FALLING, MINDCONTROLLING}
var currentPlayerState: PlayerStates
var currentMindControllee: Enemy

const SPEED = 5.0
const DASH_SPEED = 80.0
const JUMP_VELOCITY = 5.0

var coyote_time: float = .5
var jump_available: bool = true
var jump_buffer: bool = false
var jump_buffer_time: float = .1
var dashing = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():

	currentPlayerState = PlayerStates.IDLE
	death_label.text = "Death Count: " + str(Globals.death_count)
	
func _input(event):
	

	
	if event is InputEventMouseMotion:
		cam_pivot.rotate_x(-event.relative.y * .005)
		rotate_y(-event.relative.x * .005)

		cam_pivot.rotation.x = clamp(cam_pivot.rotation.x, deg_to_rad(-50), deg_to_rad(10))
	
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	
	#prints(currentPlayerState, velocity.y)
	
	match currentPlayerState:
		
		PlayerStates.IDLE:	
	
			if not is_on_floor():
				
				get_tree().create_timer(coyote_time).timeout.connect(coyote_timeout)
				set_state(PlayerStates.FALLING)
			
			else:
				jump_available = true
				if jump_buffer:
					jump()
					jump_buffer = false	
					
			# Handle jump.
			if Input.is_action_just_pressed("jump"):
				if jump_available:
					jump()

			animation_player.play("Idle")
			
			var input_dir = Input.get_vector("left", "right", "forward", "back")
			if input_dir != Vector2.ZERO:
				set_state(PlayerStates.MOVING)
				
			try_shooting()

			move_and_slide()
			
		PlayerStates.MOVING:
			
			if not is_on_floor():
				
				get_tree().create_timer(coyote_time).timeout.connect(coyote_timeout)
				set_state(PlayerStates.FALLING)
			
			else:
				jump_available = true
				if jump_buffer:
					jump()
					jump_buffer = false	
			
			var input_dir = Input.get_vector("left", "right", "forward", "back")
			if input_dir == Vector2.ZERO:
				set_state(PlayerStates.IDLE)
				
			if Input.is_action_just_pressed("jump"):
				if jump_available:
					jump()
			
			animation_player.play("Walk")
			
			try_shooting()
			control_lateral_movement()
			move_and_slide()
			
		PlayerStates.JUMPING:
			if is_on_floor():
				set_state(PlayerStates.IDLE)
			
			control_lateral_movement()
			try_shooting()
			

			
			
			velocity.y -= gravity * delta
			
			if velocity.y <= 0:
				set_state(PlayerStates.FALLING)
			
			#Play Jumping animation here
			
			animation_player.play("Control_001")
			
			move_and_slide()
			
		PlayerStates.FALLING:
			if is_on_floor():
				set_state(PlayerStates.IDLE)
			
			control_lateral_movement()
			try_shooting()
			
			#Enable jump buffer if pressed while falling
			if Input.is_action_just_pressed("jump"):
				if jump_available:
					jump()
				else:
					jump_buffer = true
					get_tree().create_timer(jump_buffer_time).timeout.connect(jump_buffer_disable)
			
			animation_player.play("Control_001")
			
			#fall faster than you jump in platformers
			velocity.y -= gravity * delta * 2.5
			
			#Play Falling animation here
			
			move_and_slide()
		
		PlayerStates.MINDCONTROLLING:
			if currentMindControllee == null:
				set_state(PlayerStates.IDLE)
			else:
				if currentMindControllee.velocity.y <= 4:
					dashing = false
				
				animation_player.play("Control_001")
				control_enemy_lateral_movement()
				check_ability()
				position = currentMindControllee.slug_attach_point.global_position
				currentMindControllee.transform.basis = transform.basis
				lose_control_of_enemy()
			
			
func set_state(new_state: PlayerStates):
	currentPlayerState = new_state


func control_enemy_lateral_movement():

	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and dashing == false:
		currentMindControllee.velocity.x = direction.x * SPEED
		currentMindControllee.velocity.z = direction.z * SPEED
	else:
		currentMindControllee.velocity.x = move_toward(	currentMindControllee.velocity.x, 0, SPEED)
		currentMindControllee.velocity.z = move_toward(	currentMindControllee.velocity.z, 0, SPEED)

func check_ability():
	if Input.is_action_just_pressed("action"):
		
		print(currentMindControllee.enemy_type)
		match currentMindControllee.enemy_type:
			#Ninja
			1:
				if currentMindControllee.is_on_floor():
					var direction = (transform.basis * Vector3(0, 0, -1)).normalized()
					if direction:
						currentMindControllee.velocity.x = direction.x * DASH_SPEED
						currentMindControllee.velocity.z = direction.z * DASH_SPEED
						currentMindControllee.velocity.y = 5.0
						dashing = true
					
			#Unknown
			_:
				pass

func control_lateral_movement():
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

	set_state(PlayerStates.MINDCONTROLLING)
	currentMindControllee = controlled_enemy
	currentMindControllee.setTeamPlayer()
	position = currentMindControllee.slug_attach_point.global_position
	currentMindControllee.take_control()

	

func lose_control_of_enemy():
	if Input.is_action_just_pressed("jump"):
		jump_available = false
		currentMindControllee.lose_control()
		currentMindControllee.setTeamEnemy()
		currentMindControllee = null
		var direction = (transform.basis * Vector3(0, 0, 1)).normalized()
		var recoil_strength = 30
		velocity.y = JUMP_VELOCITY
		velocity.x = direction.x * recoil_strength
		velocity.z = direction.z * recoil_strength
		set_state(PlayerStates.JUMPING)

func jump():
	velocity.y = JUMP_VELOCITY
	jump_available = false
	set_state(PlayerStates.JUMPING)

func recoil(from_location: Vector3 = position):
	var direction = ((position - from_location).normalized())
	var recoil_strength = 40
	velocity.y = JUMP_VELOCITY
	velocity.x = direction.x * recoil_strength
	velocity.z = direction.z * recoil_strength

func coyote_timeout():
	jump_available = false

func jump_buffer_disable():
	jump_buffer = false

func die():
	
	Globals.death_count += 1
	emit_signal("player_died")
	call_deferred("queue_free")
