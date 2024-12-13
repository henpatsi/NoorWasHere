extends Node

@export_category("Settings")
## Strength of the lerp to align photo when almost aligned
@export var align_lerp_strength: float = 2
## Rect containing shader to use when teleporting into picture
@export var teleport_shader_rect: ColorRect
@export var picture_swap_time: float = 0.3

@export_category("Audio")
@onready var transition_audio_player: AudioStreamPlayer3D = $"TransitionAudioPlayer"
@onready var swap_picture_audio_player: AudioStreamPlayer3D = $"SwapPictureAudioPlayer"
@export var transition_in_audio_clip: AudioStream
@export var transition_out_audio_clip: AudioStream
@export var swap_picture_audio: AudioStream

var picture_index: int = 0
var entered_picture_index_array: Array[int] = [0, 0, 0]
var current_picture: Node
var current_picture_array: Array[Node]
@onready var inventory: Node = %Inventory

var picture_requirements_met: Array[String]

var up_position: bool = false
var inspecting: bool = false
var aligned: bool = false
var picture_depth: int = 0

var player_target_position: Vector3
var player_target_rotation: Vector3

var input_blockers: int = 0

@onready var crosshair: ColorRect = $"../UI/Crosshair"
@onready var interact_label: Label = $"../UI/InteractLabel"
@onready var interact_response_label: Label = $"../UI/InteractResponseLabel"

@onready var player: CharacterBody3D = $"../Player"
@onready var head_node: Node3D = $"../Player/HeadNode"

var exit_area_tester: PackedScene = preload("res://levels/areas/exit_zone_tester.tscn")
var entered_picture

@onready var picture_rect = $PictureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_picture_array(inventory.get_pictures(picture_depth))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not current_picture:
		return

	if up_position and picture_rect.at_target_position:
		inspecting = true

	if inspecting and current_picture.player_in_correct_position(head_node):
		player.position = lerp(player.position, current_picture.get_local_camera_pos(), align_lerp_strength * delta)
		player.rotation.y = lerpf(player.rotation.y, current_picture.camera.rotation.y, align_lerp_strength * delta)
		head_node.rotation.x = lerpf(head_node.rotation.x, current_picture.camera.rotation.x, align_lerp_strength * delta)
		aligned = true
		interact_label.text = "Enter picture"
	else:
		aligned = false


func initialize_picture_array(array: Array[Node]) -> void:
	current_picture_array = array

	if current_picture_array.size() != 0:
		picture_index = entered_picture_index_array[picture_depth]
		current_picture = inventory.get_picture(current_picture_array, picture_index)
		current_picture.set_active(true)
	else:
		current_picture = null


func set_input_state(state: bool) -> void:
	if state == false:
		input_blockers += 1
	else:
		input_blockers -= 1
	print("Picture input blockers: " + str(input_blockers))


func _input(event: InputEvent) -> void:
	if input_blockers > 0:
		if event.is_action_pressed("exit_picture"):
			interact_response_label.change_text("Cannot exit picture right now")
		return

	input_blockers += 1

	if event.is_action_pressed("exit_picture"):
		exit_picture()

	if not current_picture:
		input_blockers -= 1
		return

	if event.is_action_pressed("inspect_picture"):
		toggle_inspect()

	if event.is_action_pressed("next_picture"):
		print("Swapping to next picture")
		swap_picture(picture_index + 1)

	if event.is_action_pressed("previous_picture"):
		print("Swapping to previous picture")
		swap_picture(picture_index - 1)

	if event.is_action_pressed("enter_picture"):
		if not inspecting:
			input_blockers -= 1
			return
		print("Trying to enter picture")
		if not aligned:
			print ("Not aligned to picture")
			input_blockers -= 1
			return
		if not current_picture.requirements_met(picture_requirements_met):
			interact_response_label.change_text("Something is missing")
			input_blockers -= 1
			return
		enter_picture()

	input_blockers -= 1


func set_inspect(state: bool) -> void:
	up_position = state

	if not up_position:
		inspecting = false
		crosshair.show()
		player.interact_enabled = true
	else:
		crosshair.hide()
		player.interact_enabled = false


func toggle_inspect() -> void:
	print("Toggling inspect")
	var state = not up_position
	set_inspect(state)
	picture_rect.set_up(state)


func enter_picture() -> void:
	print("Entering picture")

	set_input_state(false)
	player.process_mode = Node.PROCESS_MODE_DISABLED

	if transition_audio_player and transition_in_audio_clip:
		transition_audio_player.stream = transition_in_audio_clip
		transition_audio_player.play()

	if teleport_shader_rect:
		teleport_shader_rect.on_enter_picture()

	await picture_rect.enter_picture()

	#var local_camera_pos = current_picture.get_local_camera_pos()
	#var moveTween = create_tween().set_parallel()
	#moveTween.tween_property(player, "global_position:x", local_camera_pos.x, 0.2)
	#moveTween.tween_property(player, "global_position:z", local_camera_pos.z, 0.2)
	#moveTween.tween_property(player, "rotation:y", current_picture.camera.global_rotation.y, 0.2)
	#moveTween.tween_property(head_node, "rotation:x", current_picture.camera.global_rotation.x, 0.2)
#
	#await get_tree().create_timer(0.2).timeout

	player.global_position = current_picture.camera.global_position
	player.position.y -= head_node.position.y
	player.rotation.y = current_picture.camera.global_rotation.y
	head_node.rotation.x = current_picture.camera.global_rotation.x

	current_picture.enter_picture(head_node)

	entered_picture = current_picture
	entered_picture_index_array[picture_depth] = picture_index
	picture_index = 0
	picture_depth += 1
	initialize_picture_array(inventory.get_pictures(picture_depth))

	set_inspect(false)

	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	set_input_state(true)	


func exit_picture() -> void:
	if picture_depth == 0:
		print("Not inside picture")
		return

	if not await test_if_exit_possible():
		return

	print("Exiting picture")

	set_input_state(false)
	player.process_mode = Node.PROCESS_MODE_DISABLED

	if transition_audio_player and transition_out_audio_clip:
		transition_audio_player.stream = transition_out_audio_clip
		transition_audio_player.play()
	
	if teleport_shader_rect:
		teleport_shader_rect.on_exit_picture()

	inventory.clear_pictures(picture_depth)
	picture_depth -= 1
	initialize_picture_array(inventory.get_pictures(picture_depth))

	current_picture.exit_picture()

	player.global_position -= current_picture.world_root.position

	picture_rect.exit_picture()

	set_inspect(false)

	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	set_input_state(true)


func test_if_exit_possible() -> bool:
	var exit_area_tester_instance = exit_area_tester.instantiate()
	add_child(exit_area_tester_instance)
	exit_area_tester_instance.global_position = player.global_position
	exit_area_tester_instance.global_position -= entered_picture.world_root.position
	print(exit_area_tester_instance.global_position)

	await get_tree().create_timer(0.1).timeout

	if exit_area_tester_instance.hit_no_exit_area:
		print("Can not exit here")
		interact_response_label.change_text("Cannot exit picture here")
		exit_area_tester_instance.queue_free()
		return false

	exit_area_tester_instance.queue_free()
	return true


func on_picture_picked_up(picture: Node) -> void:
	current_picture_array.append(picture)
	set_active_picture(current_picture_array.size() - 1)
	if input_blockers == 0:
		toggle_inspect()


func swap_picture(target_index: int) -> void:
	if inventory.get_pictures(picture_depth).size() <= 1:
		print("Nothing to swap to")
		return

	set_active_picture(target_index)
	
	if swap_picture_audio_player and swap_picture_audio:
		swap_picture_audio_player.stream = swap_picture_audio
		swap_picture_audio_player.play()


func set_active_picture(index: int) -> void:
	print("Setting active picture")
	
	set_input_state(false)

	picture_rect.hide_picture()

	inspecting = false

	await get_tree().create_timer(picture_swap_time).timeout

	if current_picture:
		current_picture.set_active(false)

	current_picture = inventory.get_picture(current_picture_array, index)
	current_picture.set_active(true)

	picture_index = index

	picture_rect.show_picture()

	set_input_state(true)
