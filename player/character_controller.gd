extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_category("Movement")
@export var max_move_speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var crouch_ratio: float = 0.5
@export var crouch_move_speed_modifier: float = 0.5
@export var crouch_speed: float = 10

var crouching: bool = false
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var collision_shape_original_height: float = collision_shape.shape.height
@onready var collision_shape_target_height: float = collision_shape_original_height

@export_category("Camera")
@export var mouse_sensitivity: float = 10
@export var ambient_headbob_amplitude: float = 0.15
@export var ambient_headbob_frequency: float = 1

@onready var head_node: Node3D = $HeadNode
@onready var head_node_original_y: float = head_node.position.y
@onready var head_node_target_y: float = head_node_original_y
var mouse_input: Vector2
var ambient_headbob_time: float = 0

@export_category("Audio")
@export var dialogue_audio_player: AudioStreamPlayer3D
@export var subtitle_label: Label

@onready var footstep_player = $FootstepPlayer


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

	crouch_transition(delta)
	raycast()


# MOVE

func move(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var current_max_move_speed = max_move_speed
	if crouching:
		current_max_move_speed *= crouch_move_speed_modifier
	
	if direction:
		velocity.x = direction.x * current_max_move_speed
		velocity.z = direction.z * current_max_move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_max_move_speed)
		velocity.z = move_toward(velocity.z, 0, current_max_move_speed)
	
	if is_on_floor() and (abs(velocity.x) > 0 or abs(velocity.z) > 0):
		footstep_player.movement_process(delta)

# LOOK

func look(delta: float) -> void:
	ambient_headbob(delta)

	head_node.rotate_x(deg_to_rad(-mouse_input.y) * mouse_sensitivity * delta)
	head_node.rotation.x = clampf(head_node.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	rotate_y(deg_to_rad(-mouse_input.x) * mouse_sensitivity * delta)
	mouse_input = Vector2.ZERO

func ambient_headbob(delta: float) -> void:
	ambient_headbob_time += delta * ambient_headbob_frequency
	var headbob_height = cos(ambient_headbob_time) * ambient_headbob_amplitude * 0.1
	head_node.rotate_x(deg_to_rad(headbob_height))


func crouch_transition(delta: float) -> void:
	if not is_on_floor():
		crouch(false)
	head_node.position.y = lerpf(head_node.position.y, head_node_target_y, crouch_speed * delta)
	collision_shape.shape.height = lerpf(collision_shape.shape.height, collision_shape_target_height, crouch_speed * delta)
	collision_shape.position.y = collision_shape.shape.height / 2


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
		if ray_collision_object.one_shot and ray_collision_object.interacted_with:
			set_interact_message("")
		else:
			set_interact_message(ray_collision_object.verb + " " + ray_collision_object.item_name)
	else:
		set_interact_message("")

func on_item_picked_up(item: Node3D) -> void:
	inventory.add_item(item.variable_name)
	set_interact_response_message("Picked up " + item.item_name)

func on_picture_picked_up(picture: Node3D) -> void:
	picture_handler.on_picture_picked_up(picture.picture)
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

	if inspect_mode:
		return

	if event.is_action_pressed("crouch"):
		crouch(true)
	if event.is_action_released("crouch"):
		crouch(false)


func interact_input() -> void:
	if interacting_object:
		if not interacting_object.release():
			return
		if interacting_object.has_method("inspect"):
			inspect_mode = false
		interacting_object = null
		return

	if not ray_collision_object:
		print("Did not hit anything")
		return
	if not ray_collision_object.has_method("interact"):
		print("Hit object not interactable: ", ray_collision_object.name)
		return

	if ray_collision_object.one_shot and ray_collision_object.interacted_with:
		print("One shot, already interacted with", ray_collision_object.name)
		return

	interacting_object = ray_collision_object.interact(self)
	if interacting_object and interacting_object.has_method("inspect"):
		inspect_mode = true


func crouch(state: bool) -> void:
	if state:
		if not crouching:
			head_node_target_y = head_node.position.y * crouch_ratio
			collision_shape_target_height = collision_shape.shape.height * crouch_ratio
	else:
		head_node_target_y = head_node_original_y
		collision_shape_target_height = collision_shape_original_height

	crouching = state


# DIALOGUE

func set_subtitle(message: String) -> void:
	if subtitle_label:
		subtitle_label.text = message
