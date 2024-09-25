extends Node

@export_category("Settings")
## The speed at which a picture moves to/from the inspect position.
@export var inspect_speed: float = 10
## The speed at which a picture moves when it is swapped
@export var swap_speed: float = 5
## The position of the picture when not being inspected
@export var picture_lower_position: Vector2 = Vector2(320, 570)
## The position of the picture when not active
@export var picture_inventory_position: Vector2 = Vector2(1280, 2280)
## Strength of the lerp to align photo when almost aligned
@export var align_lerp_strength: float = 2

var picture_upper_position: Vector2

var picture_index: int = 0
var entered_picture_index_array: Array[int] = [0, 0, 0]
var current_picture: TextureRect
var current_picture_array: Array[TextureRect]
@onready var inventory: Node = %Inventory

var picture_requirements_met: Array[String]

var up_position: bool = false
var inspecting: bool = false
var aligned: bool = false
var picture_depth: float = 0

var player_target_position: Vector3
var player_target_rotation: Vector3

var input_blockers: float = 0

@onready var crosshair: ColorRect = $"../UI/Crosshair"
@onready var interact_label: Label = $"../UI/InteractLabel"
@onready var interact_response_label: Label = $"../UI/InteractResponseLabel"

@onready var player: CharacterBody3D = $"../Player"
@onready var head_node: Node3D = $"../Player/HeadNode"

@onready var transition_audio_player: AudioStreamPlayer3D = $"TransitionPlayer"
var transition_in_audio_clip: AudioStream = load("res://assets/audio/sfx/Misc/Transition/Photo_transition1.wav")
var transition_out_audio_clip: AudioStream = load("res://assets/audio/sfx/Misc/Transition/Photo_transition2.wav")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for picture in inventory.get_pictures(picture_depth):
		picture.set_target_position(picture_inventory_position, 100)
		picture.set_active(false)
		picture.show()

	initialize_picture_array(inventory.get_pictures(picture_depth))

	if current_picture:
		picture_upper_position = Vector2(get_viewport().size / 2) - (current_picture.size / 2)
	else: # Should not be empty at start, but just in case
		picture_upper_position = Vector2(320, 180)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not current_picture:
		return

	if up_position and current_picture.at_target_position:
		inspecting = true

	if inspecting and current_picture.player_in_correct_position(head_node):
		player.position = lerp(player.position, current_picture.get_local_camera_pos(), align_lerp_strength * delta)
		player.rotation.y = lerpf(player.rotation.y, current_picture.camera.rotation.y, align_lerp_strength * delta)
		head_node.rotation.x = lerpf(head_node.rotation.x, current_picture.camera.rotation.x, align_lerp_strength * delta)
		aligned = true
		interact_label.text = "Enter picture"
	else:
		aligned = false


func initialize_picture_array(array: Array[TextureRect]) -> void:
	current_picture_array = array

	if current_picture_array.size() != 0:
		current_picture = current_picture_array[0]
		current_picture.set_target_position(picture_lower_position, inspect_speed)
		current_picture.set_active(true)
	else:
		current_picture = null


func set_input_state(state: bool, force_down: bool = true) -> void:
	if state == false:
		input_blockers += 1
	else:
		input_blockers -= 1
	print("Picture input blockers: " + str(input_blockers))
	if input_blockers > 0 and up_position and force_down:
		toggle_inspect()


func _input(event: InputEvent) -> void:
	if input_blockers > 0:
		return

	if event.is_action_pressed("exit_picture"):
		exit_picture()

	if not current_picture:
		return

	if event.is_action_pressed("inspect_picture"):
		toggle_inspect()

	if event.is_action_pressed("next_picture"):
		print("Swapping to next picture")
		set_active_picture(picture_index + 1)
	
	if event.is_action_pressed("previous_picture"):
		print("Swapping to previous picture")
		set_active_picture(picture_index - 1)
	
	if event.is_action_pressed("enter_picture"):
		if not inspecting:
			return
		print("Trying to enter picture")
		if not aligned:
			print ("Not aligned to picture")
			return
		if not current_picture.requirements_met(picture_requirements_met):
			interact_response_label.change_text("Something is missing")
			return
		enter_picture()


func toggle_inspect() -> void:
	up_position = not up_position

	if not up_position:
		inspecting = false
		crosshair.show()
		player.interact_enabled = true
		current_picture.set_target_position(picture_lower_position, inspect_speed)
	else:
		crosshair.hide()
		player.interact_enabled = false
		current_picture.set_target_position(picture_upper_position, inspect_speed)


func enter_picture() -> void:
	print("Entering picture")

	if transition_audio_player and transition_in_audio_clip:
		transition_audio_player.stream = transition_in_audio_clip
		transition_audio_player.play()

	entered_picture_index_array[picture_depth] = picture_index
	picture_index = 0
	picture_depth += 1
	current_picture.enter_picture(player, head_node, self)
	crosshair.show()
	player.interact_enabled = true

	initialize_picture_array(inventory.get_pictures(picture_depth))


func exit_picture() -> void:
	print("Exiting picture")

	if picture_depth == 0:
		return

	current_picture.set_target_position(picture_inventory_position, 100)
	inventory.clear_pictures(picture_depth)

	picture_depth -= 1

	if transition_audio_player and transition_out_audio_clip:
		transition_audio_player.stream = transition_out_audio_clip
		transition_audio_player.play()

	initialize_picture_array(inventory.get_pictures(picture_depth))
	current_picture = inventory.get_picture(current_picture_array, entered_picture_index_array[picture_depth])

	current_picture.exit_picture(player, self)
	up_position = false


func on_picture_picked_up(picture: TextureRect) -> void:
	current_picture_array.append(picture)
	picture.position = picture_inventory_position
	picture.show()
	set_active_picture(current_picture_array.size() - 1)
	toggle_inspect()


func set_active_picture(index: int) -> void:
	inspecting = false

	if current_picture:
		current_picture.set_target_position(picture_inventory_position, swap_speed)
		current_picture.set_active(false)

	current_picture = inventory.get_picture(current_picture_array, index)
	current_picture.set_active(true)

	picture_index = index

	if up_position:
		current_picture.set_target_position(picture_upper_position, swap_speed * 2)
	else:
		current_picture.set_target_position(picture_lower_position, swap_speed * 2)
