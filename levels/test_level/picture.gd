extends TextureRect

@onready var player: CharacterBody3D = $"../../../Player"
@onready var player_camera: Camera3D = $"../../../Player/HeadNode/Camera3D"
@onready var camera_match_position: Node3D = $"../../../Player/HeadNode/CameraMatchPosition"

@onready var black_bars: ColorRect = $"../../BlackBars"

@export_group("References")
## The camera that is rendered on the sub viewport.
@export var camera: Camera3D
## The root of the world where the camera is located.
@export var world_root: Node3D

@export_group("Settings")
## The time (s) it takes for the picture to move to/from the inspect position.

## For lining up the picture and the real scene.
## The maxumim distance the player can be from the actual position.
@export var match_position_distance: float = 0.5
## For lining up the picture and the real scene.
## The maxumim rotation the player can be from the actual rotation.
@export var match_rotation_distance: float = 10

## The height of the top of the picture when not being inspected.

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

#var printTimer = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = create_tween() #TODO check why this is needed, does not fade to black without a at 255 at start
	tween.tween_property(black_bars, "modulate:a", 0, 0.1) 

func set_active(state: bool, picture_handler: Node) -> void:
	active_picture = state
	
	inspect_speed = picture_handler.inspect_speed
	picture_lower_y = picture_handler.picture_lower_y

	target_position = Vector2(size.x / 4, picture_lower_y)

	if active_picture:
		for node in nodes_to_show:
			node.show()

	if not active_picture:
		for node in nodes_to_show:
			node.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not active_picture or busy:
		return

	if inside_picture:
		inside_picture_process(delta)
	else:
		outside_picture_process(delta)

func inside_picture_process(_delta: float) -> void:
	camera.global_position = player_camera.global_position
	camera.global_rotation = player_camera.global_rotation
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
	#printTimer += delta
	#if (printTimer > 1):
		#printTimer = 0
		#print(camera_match_position.global_position)
		#print(camera.position - world_root.position)
		#print(player_camera.global_rotation)
		#print(camera.rotation)
		#print("pos distance:")
		#print(camera_match_position.global_position.distance_to(camera.position - world_root.position))
		#print("rot distance:")
		#print(player_camera.global_rotation.distance_to(camera_picture_rotation))

	if camera_match_position.global_position.distance_to(camera.position - world_root.position) > match_position_distance:
		return
	if player_camera.global_rotation.distance_to(camera_picture_rotation) > deg_to_rad(match_rotation_distance):
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
		target_position.y = size.y / 4


func enter_picture() -> void:
	busy = true

	inside_picture = true
	player.process_mode = Node.PROCESS_MODE_DISABLED

	var fadeTween = create_tween()
	fadeTween.tween_property(black_bars, "modulate:a", 1, 1)
	
	var zoomTween = create_tween().set_parallel()
	zoomTween.tween_property(self, "position:y", 0, 1)
	zoomTween.tween_property(self, "position:x", 0, 1)
	zoomTween.tween_property(self, "scale:x", 1, 1)
	zoomTween.tween_property(self, "scale:y", 1, 1)

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

	var fadeTween = create_tween()
	fadeTween.tween_property(black_bars, "modulate:a", 0, 1)
	
	var zoomTween = create_tween().set_parallel()
	zoomTween.tween_property(self, "position:y", 570, 1)
	zoomTween.tween_property(self, "position:x", 320, 1)
	zoomTween.tween_property(self, "scale:x", 0.5, 1)
	zoomTween.tween_property(self, "scale:y", 0.5, 1)
	
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
