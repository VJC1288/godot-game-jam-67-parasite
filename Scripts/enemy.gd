extends CharacterBody3D

class_name Enemy

@onready var exclamation = $Exclamation
@onready var slug_attach_point = $SlugAttachPoint
@onready var mesh_node = $Mesh
@onready var collision_shape_3d = $CollisionShape3D
@onready var player_detector = $SightPivot/PlayerDetector

enum EnemyMoveStates {IDLE = 1, CHASING, PATROLING, MINDCONTROLLED}
var currentMoveState: EnemyMoveStates
var chaseTarget

#enum EnemyTeamStates {ENEMY = 1, PLAYER}
#var currentTeamState: EnemyTeamStates
#


const SPEED = 3.0
const JUMP_VELOCITY = 4.5
var height

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	currentMoveState = EnemyMoveStates.IDLE
	height = mesh_node.mesh.height

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	match currentMoveState:
		EnemyMoveStates.IDLE:
			
			velocity.y -= gravity * delta
			move_and_slide()
			
		EnemyMoveStates.CHASING:
			
			#Makes the Enemy look at the Player
			look_at(chaseTarget.global_position, Vector3.UP)
			
			#Stop the enemy from rotating on the X axis
			rotation.x = 0
			
			#Makes the Enemy Chase the Player. Enemy will chase player until Player leaves sight cone
			var direction: Vector3 = chaseTarget.global_position - global_position
			direction = direction.normalized()
			#Stop the character from moving in the Y direction
			direction.y = 0
			
			velocity = direction * SPEED
			velocity.y -= gravity * delta
			
			move_and_slide()
			
		EnemyMoveStates.MINDCONTROLLED:
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

	
