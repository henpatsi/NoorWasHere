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
@export var subtitle_label: Label

var footstep_timer: float = 0.0

@export_category("Interaction")
@export var ray_cast: RayCast3D
@export var ray_distance: float = 3.0
@export var interact_label: Label
@export var interact_response_label: Label 
@export var inspect_rotation_sensitivity: float = 15
var interact_enabled: bool = true

var ray_collision_object: Object
var interacting_object: Node
var inspect_mode: bool = false

@onready var inventory: Node = %Inventory
@onready var picture_handler: Node = %PictureHandler
@onready var inspect_position: Node3D = $HeadNode/InspectPosition


func _physics_process(delta: float) -> void:

	if inspect_mode:
		rotate_inspect(delta)
	else:
		air(delta)
		move(delta)
		look(delta)
		move_and_slide()

	raycast()


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


func rotate_inspect(delta: float) -> void:
	interacting_object.rotate_x(deg_to_rad(mouse_input.y) * inspect_rotation_sensitivity * delta)
	interacting_object.rotate_y(deg_to_rad(mouse_input.x) * inspect_rotation_sensitivity * delta)
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
	if interacting_object:
		set_interact_message("Release " + interacting_object.item_name)
		return

	ray_cast.target_position = Vector3.FORWARD * ray_distance
	ray_collision_object = ray_cast.get_collider()

	if interact_enabled and ray_collision_object and ray_collision_object.has_method("interact"):
		set_interact_message(ray_collision_object.verb + " " + ray_collision_object.item_name)
	else:
		set_interact_message("")

func on_item_picked_up(item: Node3D) -> void:
	inventory.add_item(item.variable_name)
	set_interact_response_message("Picked up " + item.item_name)

func on_picture_picked_up(picture: Node3D) -> void:
	inventory.add_picture(picture.picture)
	picture_handler.on_picture_picked_up()
	set_interact_response_message("Picked up " + picture.item_name)

func set_interact_message(message: String) -> void:
	if interact_label:
		interact_label.text = message

func set_interact_response_message(message: String) -> void:
	if interact_response_label:
		interact_response_label.change_text(message)

func add_met_picture_requirement(requirement: String) -> void:
	picture_handler.picture_requirements_met.append(requirement)
	
func set_inspect_mode(state: bool) -> void:
	inspect_mode = state
	if inspect_mode:
		print("Inspect mode on")
	else:
		print("Inspect mode off")

func set_picture_handler_input(state: bool) -> void:
	picture_handler.set_input_state(state)


# INPUT

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_input = Vector2(event.relative.x, event.relative.y) * GlobalSettings.mouse_sensitivity_modifier
	
	if event.is_action_pressed("interact") and interact_enabled:
		interact_input()

func interact_input() -> void:
	if interacting_object:
		interacting_object.release()
		if interacting_object.has_method("inspect"):
			inspect_mode = false
		interacting_object = null
		return

	if not ray_collision_object or not ray_collision_object.has_method("interact"):
		print("Did not hit an interactable")
		return

	interacting_object = ray_collision_object.interact(self)
	if interacting_object and interacting_object.has_method("inspect"):
		inspect_mode = true

# DIALOGUE

func set_subtitle(message: String) -> void:
	if subtitle_label:
		subtitle_label.text = message
