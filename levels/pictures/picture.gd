extends TextureRect

@export_group("References")
## The camera that is rendered on the sub viewport.
@export var camera: Camera3D
## The root of the world where the camera is located.
@export var world_root: Node3D


@export_group("Settings")
## For lining up the picture and the real scene.
## The maxumim distance the player can be from the actual position.
@export var match_position_distance: float = 2
## For lining up the picture and the real scene.
## The maxumim rotation the player can be from the actual rotation.
@export var match_rotation_distance: float = 10
## A list of requirements that need to be met for this picture to work.
## Example: front_door_closed, tv_on_table, living_room_complete
@export var requirements: Array[String]


@export_group("Picture Specific Objects")
## Nodes that will be shown when picture is active and hidden when inactive
@export var nodes_to_show: Array[Node]
## Nodes that will be hidden when picture is active and shown when inactive
@export var nodes_to_hide: Array[Node]
## Nodes that will only be hidden once exiting the photo.
## Useful if something is shown through an interaction within the photo.
@export var nodes_to_hide_on_exit: Array[Node]


@export_group("Audio")
## Audio stream player to play audio when scene is entered
@export var ambientASP: AudioStreamPlayer3D
## Audio stream that is played when scene is entered
@export var ambientAS: AudioStream
## Volume db that the fade in starts from
@export var starting_volume: float = -20
@export var ending_volume: float = 20
## Time it takes music to fade in from silent to the original value
@export var volume_fade_in_time: float = 3


@export_group("Dialogue")
## Dialogue to play as player enters the picture
@export var enter_dialogue_clips: Array[Resource]
## Dialogue to play as player exits the picture
@export var exit_dialogue_clips: Array[Resource]
## Delay before enter dialogue played
@export var enter_dialogue_delay: float = 0
## Delay before exit dialogue played
@export var exit_dialogue_delay: float = 0
## If true, cannot use picture input until dialogue played.
@export var prevent_teleport: bool = true

var dialogue_clips
var dialogue_delay
var dialogue_index = 0
var dialogue_playing: bool = false
var enter_dialogue_triggered: bool = false
var exit_dialogue_triggered: bool = false


@export_group("Scene Changes")
## Nodes that will be shown when picture is entered
@export var enter_nodes_to_show: Array[Node]
## Nodes that will be hidden when picture is entered
@export var enter_nodes_to_hide: Array[Node]
## Nodes that will be shown when picture is exited
@export var exit_nodes_to_show: Array[Node]
## Nodes that will be hidden when picture is exited
@export var exit_nodes_to_hide: Array[Node]
## Area3D nodes that should start monitoring when entered
@export var enter_start_monitoring_list: Array[Area3D]
## Area3D nodes that should start monitoring when exit
@export var exit_start_monitoring_list: Array[Area3D]
## Waits until all dialogue clips have been played until making the listed changes.
@export var changes_wait_for_dialogue: bool = true

var nodes_to_show_transition
var nodes_to_hide_transition
var start_monitoring_list_transition

@export_group("Transition")
## Time it takes to perfectly position player
@export var move_tween_time: float = 0.2
## Time it takes to resize picture to full screen
@export var picture_resize_time: float = 1.0

var active_picture: bool = false
var inside_picture: bool = false

var camera_follow_node: Node3D

var audioTween: Tween

@onready var camera_picture_position: Vector3 = camera.global_position
@onready var camera_picture_rotation: Vector3 = camera.global_rotation

@onready var target_position: Vector2 = Vector2(1000, 1000)
var move_speed: float = 100
var at_target_position: bool = false

@onready var picture_shader: ColorRect = $"../SubViewport/PortalCamera/Shader"

@onready var player: CharacterBody3D = %Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_active(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	dialogue_process()

	if not at_target_position:
		position = lerp(position, target_position, move_speed * delta)
		if position.distance_to(target_position) < 1:
			at_target_position = true

	if not inside_picture:
		return

	camera.global_position = camera_follow_node.global_position
	camera.global_rotation = camera_follow_node.global_rotation

func set_target_position(pos: Vector2, speed: float) -> void:
	print(name, " pos = ", pos)
	at_target_position = false
	target_position = pos
	move_speed = speed

func set_active(state: bool) -> void:
	active_picture = state
	apply_scene_changes(state, nodes_to_show, nodes_to_hide)

func get_local_camera_pos() -> Vector3:
	var camera_pos = camera.position - world_root.position
	camera_pos.y -= 1.5
	return camera_pos


func player_in_correct_position(head_node: Node3D) -> bool:
	if head_node.global_position.distance_to(camera.position - world_root.position) > match_position_distance:
		return false
	elif head_node.global_rotation.distance_to(camera_picture_rotation) > deg_to_rad(match_rotation_distance):
		return false
	else:
		return true


func requirements_met(met_requirements: Array[String]) -> bool:
	for requirement in requirements:
		if requirement not in met_requirements:
			return false
	return true


func enter_picture(head_node: Node3D, picture_handler: Node) -> void:
	print("Enter")
	picture_handler.set_input_state(false, false)
	player.process_mode = Node.PROCESS_MODE_DISABLED

	var camera_pos = get_local_camera_pos()
	var moveTween = create_tween().set_parallel()
	moveTween.tween_property(player, "global_position:x", camera_pos.x, move_tween_time)
	moveTween.tween_property(player, "global_position:z", camera_pos.z, move_tween_time)
	moveTween.tween_property(player, "rotation:y", camera.global_rotation.y, move_tween_time)
	moveTween.tween_property(head_node, "rotation:x", camera.global_rotation.x, move_tween_time)
	
	await get_tree().create_timer(move_tween_time).timeout

	picture_shader.on_enter_picture()

	var zoomTween = create_tween().set_parallel()
	zoomTween.tween_property(self, "position:y", 0, picture_resize_time)
	zoomTween.tween_property(self, "position:x", 0, picture_resize_time)
	zoomTween.tween_property(self, "size:x", 1280, picture_resize_time)
	zoomTween.tween_property(self, "size:y", 720, picture_resize_time)

	await get_tree().create_timer(picture_resize_time).timeout
	
	if ambientASP and ambientAS:
		ambientASP.volume_db = starting_volume
		ambientASP.stream = ambientAS
		ambientASP.play()
		audioTween = create_tween()
		audioTween.set_ease(Tween.EASE_OUT)
		audioTween.tween_property(ambientASP, "volume_db", ending_volume, volume_fade_in_time)

	player.global_position = camera.global_position
	player.position.y -= head_node.position.y
	player.rotation.y = camera.global_rotation.y
	head_node.rotation.x = camera.global_rotation.x

	player.process_mode = Node.PROCESS_MODE_PAUSABLE

	camera_follow_node = head_node
	inside_picture = true

	if not enter_dialogue_triggered and enter_dialogue_clips.size() > 0:
		start_dialogue_clips()
	elif not dialogue_playing:
		apply_scene_changes(true, enter_nodes_to_show, enter_nodes_to_hide, enter_start_monitoring_list)

	picture_handler.set_input_state(true)


func exit_picture(picture_handler: Node) -> void:
	print("Exit")

	picture_handler.set_input_state(false, false)
	player.process_mode = Node.PROCESS_MODE_DISABLED

	inside_picture = false

	picture_shader.on_exit_picture()

	for node in nodes_to_hide_on_exit:
		if is_instance_valid(node):
			node.hide()
			set_child_collider_states(node, true)

	player.global_position -= world_root.position

	var zoomTween = create_tween().set_parallel()
	zoomTween.tween_property(self, "position:y", target_position.y, picture_resize_time)
	zoomTween.tween_property(self, "position:x", target_position.x, picture_resize_time)
	zoomTween.tween_property(self, "size:x", 640, picture_resize_time)
	zoomTween.tween_property(self, "size:y", 360, picture_resize_time)

	if ambientASP and ambientAS:
		if audioTween:
			audioTween.kill()
		audioTween = create_tween()
		audioTween.set_ease(Tween.EASE_IN)
		audioTween.tween_property(ambientASP, "volume_db", -60, picture_resize_time)

	await get_tree().create_timer(picture_resize_time).timeout

	var camera_return_time: float = 0.2
	var cameraTween = create_tween().set_parallel()
	cameraTween.tween_property(camera, "global_position", camera_picture_position, camera_return_time)
	cameraTween.tween_property(camera, "global_rotation", camera_picture_rotation, camera_return_time)

	if ambientASP and ambientAS:
		ambientASP.stop()

	player.process_mode = Node.PROCESS_MODE_PAUSABLE

	await get_tree().create_timer(camera_return_time).timeout

	if not enter_dialogue_triggered and enter_dialogue_clips.size() > 0:
		start_dialogue_clips()
	elif not dialogue_playing:
		apply_scene_changes(true, exit_nodes_to_show, exit_nodes_to_hide, exit_start_monitoring_list)

	picture_handler.set_input_state(true)


func start_dialogue_clips() -> void:
	if inside_picture:
		enter_dialogue_triggered = true
		dialogue_clips = enter_dialogue_clips
		dialogue_delay = enter_dialogue_delay
		start_monitoring_list_transition = enter_start_monitoring_list
		nodes_to_show_transition = enter_nodes_to_show
		nodes_to_hide_transition = enter_nodes_to_hide
	else:
		exit_dialogue_triggered = true
		dialogue_clips = exit_dialogue_clips
		dialogue_delay = exit_dialogue_delay
		start_monitoring_list_transition = exit_start_monitoring_list
		nodes_to_show_transition = exit_nodes_to_show
		nodes_to_hide_transition = exit_nodes_to_hide

	handle_teleport_state(false)
	
	if not changes_wait_for_dialogue:
		apply_scene_changes(true, nodes_to_show_transition, nodes_to_hide_transition, start_monitoring_list_transition)
	
	if dialogue_delay > 0:
		await get_tree().create_timer(dialogue_delay).timeout

	dialogue_index = 0
	dialogue_playing = true


func dialogue_process() -> void:
	if not dialogue_playing or player.dialogue_audio_player.playing:
		return

	if dialogue_index == dialogue_clips.size():
		dialogue_playing = false
		player.set_subtitle("")
		if changes_wait_for_dialogue:
			apply_scene_changes(true, nodes_to_show_transition, nodes_to_hide_transition, start_monitoring_list_transition)
		handle_teleport_state(true)
		return

	player.dialogue_audio_player.stream = dialogue_clips[dialogue_index].audio_stream
	player.dialogue_audio_player.play()

	player.set_subtitle(dialogue_clips[dialogue_index].subtitle)

	dialogue_index += 1


func handle_teleport_state(state: bool) -> void:
	if prevent_teleport:
		player.set_picture_handler_input(state)


func apply_scene_changes(state: bool, show_nodes, hide_nodes, monitor_areas = null) -> void:
	if state == true:
		for node in show_nodes:
			if is_instance_valid(node):
				node.show()
				set_child_collider_states(node, false)
		for node in hide_nodes:
			if is_instance_valid(node):
				node.hide()
				set_child_collider_states(node, true)
		if monitor_areas:
			for area in monitor_areas:
				if area:
					area.monitoring = true
	else:
		for node in show_nodes:
			if is_instance_valid(node):
				node.hide()
				set_child_collider_states(node, true)
		for node in hide_nodes:
			if is_instance_valid(node):
				node.show()
				set_child_collider_states(node, false)


func set_child_collider_states(node: Node, disabled_state: bool) -> void:
	for child in node.get_children():
		if is_instance_valid(child):
			set_child_collider_states(child, disabled_state)
	if node is CollisionShape3D:
		node.disabled = disabled_state
	if node is CSGBox3D:
		node.use_collision = not disabled_state
