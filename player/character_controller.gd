extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var rng = RandomNumberGenerator.new()

@export var max_move_speed: float = 5.0
@export var jump_velocity: float = 4.5

@onready var head_node: Node3D = $HeadNode
@export var mouse_sensitivity: float = 10
var mouse_input: Vector2

var footstep_timer: float = 0.0
@export var footstep_audio_player: AudioStreamPlayer3D
@export var footstep_duration: float = 0.5
@export var footstep_sound_effects: Array[AudioStream]


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:

	air(delta)
	move(delta)
	look(delta)

	move_and_slide()


# MOVE

func move(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * max_move_speed
		velocity.z = direction.z * max_move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, max_move_speed)
		velocity.z = move_toward(velocity.z, 0, max_move_speed)
	
	if abs(velocity.x) > 0 or abs(velocity.z) > 0:
		footstep(delta)


func footstep(delta: float) -> void:
	if is_on_floor():
		footstep_timer += delta;
	if footstep_timer < footstep_duration:
		return

	footstep_audio_player.stream = footstep_sound_effects[rng.randi_range(0, footstep_sound_effects.size() - 1)]
	footstep_audio_player.play()

	footstep_timer = 0


# LOOK

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_input = Vector2(event.relative.x, event.relative.y) * GlobalSettings.mouse_sensitivity_modifier

func look(delta: float) -> void:
	head_node.rotate_x(deg_to_rad(-mouse_input.y) * mouse_sensitivity * delta)
	head_node.rotation.x = clampf(head_node.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	rotate_y(deg_to_rad(-mouse_input.x) * mouse_sensitivity * delta)
	mouse_input = Vector2.ZERO


# JUMP

func air(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
