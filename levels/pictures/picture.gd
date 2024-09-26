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

@export_group("Scene changes")
## Nodes that will be shown when picture is active and hidden when inactive
@export var nodes_to_show: Array[Node]
## Nodes that will be hidden when picture is active and shown when inactive
@export var nodes_to_hide: Array[Node]
## Area3D nodes that should start monitoring
@export var start_monitoring_list: Array[Area3D]
## Audio stream player to play audio when scene is entered
@export var ambientASP: AudioStreamPlayer3D
## Audio stream that is played when scene is entered
@export var ambientAS: AudioStream
## Volume db that the fade in starts from
@export var starting_volume: float = -20
@export var ending_volume: float = 20
## Time it takes music to fade in from silent to the original value
@export var volume_fade_in_time: float = 3
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

var printTimer = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_active(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

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

	if active_picture:
		for node in nodes_to_show:
			if is_instance_valid(node):
				node.show()
				set_child_collider_states(node, false)
		for node in nodes_to_hide:
			if is_instance_valid(node):
				node.hide()
				set_child_collider_states(node, true)
		for area in start_monitoring_list:
			area.monitoring = true
		#show()

	if not active_picture:
		for node in nodes_to_show:
			if is_instance_valid(node):
				node.hide()
				set_child_collider_states(node, true)
		for node in nodes_to_hide:
			if is_instance_valid(node):
				node.show()
				set_child_collider_states(node, false)
		for area in start_monitoring_list:
			area.monitoring = false
		#hide()


func set_child_collider_states(node: Node, disabled_state: bool) -> void:
	for child in node.get_children():
		if is_instance_valid(child):
			set_child_collider_states(child, disabled_state)
	if node is CollisionShape3D:
		node.disabled = disabled_state


func get_local_camera_pos() -> Vector3:
	var camera_pos = camera.position - world_root.position
	camera_pos.y -= 1.75
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


func enter_picture(player: CharacterBody3D, head_node: Node3D, picture_handler: Node) -> void:
	picture_handler.set_input_state(false, false)
	player.process_mode = Node.PROCESS_MODE_DISABLED

	var camera_pos = get_local_camera_pos()
	var moveTween = create_tween().set_parallel()
	moveTween.tween_property(player, "global_position:x", camera_pos.x, move_tween_time)
	moveTween.tween_property(player, "global_position:z", camera_pos.z, move_tween_time)
	moveTween.tween_property(player, "rotation:y", camera.rotation.y, move_tween_time)
	moveTween.tween_property(head_node, "rotation:x", camera.rotation.x, move_tween_time)
	
	await get_tree().create_timer(move_tween_time).timeout

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
	player.global_rotation = camera.global_rotation

	get_tree().root.get_child(1).set_past_environment()
	hide()

	player.process_mode = Node.PROCESS_MODE_PAUSABLE

	camera_follow_node = head_node
	inside_picture = true
	picture_handler.set_input_state(true)


func exit_picture(player: CharacterBody3D, picture_handler: Node) -> void:
	picture_handler.set_input_state(false, false)

	inside_picture = false
	show()
	get_tree().root.get_child(1).set_present_environment()

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

	if ambientASP and ambientAS:
		ambientASP.stop()

	camera.global_position = camera_picture_position
	camera.global_rotation = camera_picture_rotation
	
	picture_handler.set_input_state(true)
