extends TextureRect

@onready var player: CharacterBody3D = $"../../../Player"
@onready var head_node: Node3D = $"../../../Player/HeadNode"
@onready var picture_handler: Node = $"../.."

@export_group("References")
## The camera that is rendered on the sub viewport.
@export var camera: Camera3D
## The root of the world where the camera is located.
@export var world_root: Node3D

@export_group("Settings")
## For lining up the picture and the real scene.
## The maxumim distance the player can be from the actual position.
@export var match_position_distance: float = 0.5
## For lining up the picture and the real scene.
## The maxumim rotation the player can be from the actual rotation.
@export var match_rotation_distance: float = 10
## A list of requirements that need to be met for this picture to work.
## Example: front_door_closed, tv_on_table, living_room_complete
@export var requirements: Array[String]

@export_group("Scene changes")
## Nodes that will be shown when picture is active and hidden when inactive
@export var nodes_to_show: Array[Node]
## Audio stream player to play audio when scene is entered
@export var ambientASP: AudioStreamPlayer3D
## Audio stream that is played when scene is entered
@export var ambientAS: AudioStream
## Volume db that the fade in starts from
@export var starting_volume: float = -20
## Time it takes music to fade in from silent to the original value
@export var volume_fade_in_time: float = 3

var inspect_speed: float
var picture_lower_y: int

var active_picture: bool = false
var target_position: Vector2
var up_position: bool = false
var inspecting: bool = false
var inside_picture: bool = false
var busy: bool = false

var audioTween: Tween

@onready var camera_picture_position: Vector3 = camera.global_position
@onready var camera_picture_rotation: Vector3 = camera.global_rotation

var printTimer = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node in nodes_to_show:
		node.hide()
		set_child_collider_states(node, true)
	
	inspect_speed = picture_handler.inspect_speed
	picture_lower_y = picture_handler.picture_lower_y
	
	target_position = Vector2(size.x / 2, picture_lower_y)

func set_active(state: bool) -> void:
	active_picture = state

	if active_picture:
		for node in nodes_to_show:
			node.show()
			set_child_collider_states(node, false)
		show()

	if not active_picture:
		for node in nodes_to_show:
			node.hide()
			set_child_collider_states(node, true)
		hide()


func set_child_collider_states(node: Node, state: bool) -> void:
	for child in node.get_children():
		set_child_collider_states(child, state)
	if node is CollisionShape3D:
		node.disabled = state

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not active_picture or busy:
		return

	if inside_picture:
		inside_picture_process(delta)
	else:
		outside_picture_process(delta)

func inside_picture_process(_delta: float) -> void:
	camera.global_position = head_node.global_position
	camera.global_rotation = head_node.global_rotation
	if not inspecting:
		exit_picture()

func outside_picture_process(delta: float) -> void:
	if position.distance_to(target_position) > 1:
		position = lerp(position, target_position, inspect_speed * delta)
	else:
		if up_position and not inspecting:
			print("Inspecting")
			inspecting = true

	if inspecting:
		check_player_position()


func check_player_position() -> void:

	if head_node.global_position.distance_to(camera.position - world_root.position) > match_position_distance:
		return
	if head_node.global_rotation.distance_to(camera_picture_rotation) > deg_to_rad(match_rotation_distance):
		return

	for requirement in requirements:
		if requirement not in picture_handler.picture_requirements:
			return

	enter_picture()


func toggle_inspecting() -> void:
	if busy:
		print("Picture busy")
		return

	up_position = not up_position
	
	if not up_position:
		target_position.y = picture_lower_y
		inspecting = false
	else:
		target_position.y = size.y / 2


func enter_picture() -> void:
	busy = true

	inside_picture = true
	player.process_mode = Node.PROCESS_MODE_DISABLED

	var camera_pos = camera.position - world_root.position
	camera_pos.y = 0
	var moveTween = create_tween().set_parallel()
	moveTween.tween_property(player, "global_position:x", camera_pos.x, 0.5)
	moveTween.tween_property(player, "global_position:z", camera_pos.z, 0.5)
	moveTween.tween_property(player, "rotation:y", camera.rotation.y, 0.5)
	moveTween.tween_property(head_node, "rotation:x", camera.rotation.x, 0.5)
	
	await get_tree().create_timer(0.5).timeout

	var zoomTween = create_tween().set_parallel()
	zoomTween.tween_property(self, "position:y", 0, 1)
	zoomTween.tween_property(self, "position:x", 0, 1)
	zoomTween.tween_property(self, "size:x", 1280, 1)
	zoomTween.tween_property(self, "size:y", 720, 1)

	await get_tree().create_timer(1).timeout
	
	if ambientASP and ambientAS:
		ambientASP.volume_db = starting_volume
		ambientASP.stream = ambientAS
		ambientASP.play()
		audioTween = create_tween()
		audioTween.set_ease(Tween.EASE_OUT)
		audioTween.tween_property(ambientASP, "volume_db", 0, volume_fade_in_time)

	player.global_position = camera.global_position
	player.position.y = 0
	player.global_rotation = camera.global_rotation

	player.process_mode = Node.PROCESS_MODE_PAUSABLE

	busy = false


func exit_picture() -> void:
	busy = true

	inside_picture = false

	player.global_position -= world_root.position
	player.position.y = 0

	var zoomTween = create_tween().set_parallel()
	zoomTween.tween_property(self, "position:y", 570, 1)
	zoomTween.tween_property(self, "position:x", 320, 1)
	zoomTween.tween_property(self, "size:x", 640, 1)
	zoomTween.tween_property(self, "size:y", 360, 1)
	
	if ambientASP and ambientAS:
		if audioTween:
			audioTween.kill()
		audioTween = create_tween()
		audioTween.set_ease(Tween.EASE_IN)
		audioTween.tween_property(ambientASP, "volume_db", -60, 1)

	await get_tree().create_timer(1).timeout

	if ambientASP and ambientAS:
		ambientASP.stop()

	camera.global_position = camera_picture_position
	camera.global_rotation = camera_picture_rotation
	
	busy = false
