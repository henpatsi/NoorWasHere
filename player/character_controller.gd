extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var rng = RandomNumberGenerator.new()

@export_category("Movement")
@export var max_move_speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 10

@onready var head_node: Node3D = $HeadNode
var mouse_input: Vector2

@export_category("Audio")
@export var footstep_audio_player: AudioStreamPlayer3D
@export var footstep_duration: float = 0.5
@export var footstep_sound_effects: Array[AudioStream]
@export var dialogue_audio_player: AudioStreamPlayer3D

var footstep_timer: float = 0.0

@export_category("Raycast")
@export var ray_cast: RayCast3D
@export var ray_distance: float = 3.0
@export var interact_label: Label
var interact_enabled: bool = true

var ray_collision_object: Object
var interacting_object: Node

@onready var inventory: Node = $Inventory
@onready var inspect_position: Node3D = $HeadNode/InspectPosition


func _physics_process(delta: float) -> void:

	air(delta)
	move(delta)
	look(delta)

	raycast()

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


# INTERACT

func raycast() -> void:
	ray_cast.target_position = Vector3.FORWARD * ray_distance
	ray_collision_object = ray_cast.get_collider()

	if ray_collision_object and ray_collision_object.is_in_group("Interactable"):
		if interact_label and interact_enabled:
			interact_label.text = "Interact with " + ray_collision_object.item_name
	elif interact_label:
		interact_label.text = ""

# INPUT

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_input = Vector2(event.relative.x, event.relative.y) * GlobalSettings.mouse_sensitivity_modifier
	
	if event.is_action_pressed("interact") and interact_enabled:
		if not ray_collision_object or not ray_collision_object.is_in_group("Interactable"):
			print("Did not hit an interactable")
			return
		if interacting_object and ray_collision_object != interacting_object:
			print("Already interacting with " + interacting_object.name)
			return
		interacting_object = ray_collision_object.interact(self)
