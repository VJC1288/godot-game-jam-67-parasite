extends CharacterBody3D

class_name Enemy

enum EnumEnemyTypes {NONE = 0, NINJA = 1}

@onready var exclamation = $Exclamation
@onready var slug_attach_point = $SlugAttachPoint
@onready var mesh_node = $Mesh
@onready var collision_shape_3d = $CollisionShape3D
@onready var player_detector = $SightPivot/PlayerDetector

@export var enemy_model: Node3D
@export var enemy_type: EnumEnemyTypes

var enemy_animation_player: AnimationPlayer

enum EnemyMoveStates {IDLE = 1, CHASING, PATROLING, MINDCONTROLLED}
var currentMoveState: EnemyMoveStates
var chaseTarget


var startingPosition: Vector3

#enum EnemyTeamStates {ENEMY = 1, PLAYER}
#var currentTeamState: EnemyTeamStates

const SPEED = 3.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	currentMoveState = EnemyMoveStates.IDLE
	if enemy_model != null:
		enemy_animation_player = enemy_model.get_node("AnimationPlayer")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	match currentMoveState:
		EnemyMoveStates.IDLE:
			
			enemy_animation_player.play("Idle")
			velocity.z = 0
			velocity.x = 0
			velocity.y -= gravity * delta
			move_and_slide()
			
		EnemyMoveStates.CHASING:
			
			enemy_animation_player.play("Run")
						
			#Makes the Enemy look at the Player
			look_at(chaseTarget.global_position, Vector3.UP)
			
			#Stop the enemy from rotating on the X axis
			rotation.x = 0
			
			#Makes the Enemy Chase the Player. Enemy will chase player until Player leaves sight cone
			var direction: Vector3 = chaseTarget.global_position - global_position
			direction = direction.normalized()
			
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			velocity.y -= gravity * delta
			
			move_and_slide()
			
		EnemyMoveStates.MINDCONTROLLED:
			
			if velocity != Vector3.ZERO:
				enemy_animation_player.play("Run")
			else:
				enemy_animation_player.play("Idle")
			
			move_and_slide()

			
func setMoveState(new_state):
	currentMoveState = new_state


func _on_player_detector_body_entered(body):
	#Starts chasing Player
	if body.is_in_group("player"):
		chaseTarget = body
		setMoveState(EnemyMoveStates.CHASING)
		exclamation.visible = true


func _on_player_detector_body_exited(body):
	#Stops chasing Player
	if body.is_in_group("player"):
		chaseTarget = null
		velocity = Vector3.ZERO
		setMoveState(EnemyMoveStates.IDLE)
		exclamation.visible = false

func take_control():
	player_detector.monitoring = false
	setMoveState(EnemyMoveStates.MINDCONTROLLED)
	
func lose_control():
	player_detector.monitoring = true
	setMoveState(EnemyMoveStates.IDLE)	

func die():
	queue_free()
	
