extends TextureRect

@onready var player: CharacterBody3D = $"../../../Player"
@onready var player_camera: Camera3D = $"../../../Player/HeadNode/Camera3D"

@onready var black_bars: ColorRect = $"../../../BlackBars"

@export var camera: Camera3D
@onready var camera_picture_position: Vector3 = camera.global_position
@onready var camera_picture_rotation: Vector3 = camera.global_rotation

@export var world_offset: Vector3

var inspecting: bool = false
var inside_picture: bool = false
var camera_follow: bool = false

var printTimer = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = create_tween()
	tween.tween_property(black_bars, "modulate:a", 0, 0.1) #TODO check why this is needed, does not fade to black without a at 255 at start
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	printTimer += delta
	if camera_follow:
		camera.global_position = player_camera.global_position
		camera.global_rotation = player_camera.global_rotation

func check_player_position() -> void:
	if not inspecting or inside_picture:
		return

	if (printTimer > 1):
		printTimer = 0
		print(player.position)
		print(camera.position - world_offset)
		print(player.rotation)
		print(camera.rotation)
	
	var campos = camera.position
	campos.y = 0

	if player.position.distance_to(campos - world_offset) > 1:
		return
	if player.rotation.distance_to(camera_picture_rotation) > 0.5:
		return
	
	enter_picture()

func toggle_inspecting() -> void:
	inspecting = not inspecting
	var tween = create_tween()
	if inspecting:
		tween.tween_property(self, "position:y", 180, 1)
	else:
		tween.tween_property(self, "position:y", 570, 1)

	if inside_picture:
		exit_picture()

func enter_picture() -> void:
	if not inspecting:
		print("Must be inspecting to enter picture")
		return
	if inside_picture:
		print("Already inside picture")
		return
	
	inside_picture = true

	var fadeTween = create_tween()
	fadeTween.tween_property(black_bars, "modulate:a", 1, 1)
	
	var zoomTween = create_tween().set_parallel()
	zoomTween.tween_property(self, "position:y", 0, 1)
	zoomTween.tween_property(self, "position:x", 0, 1)
	zoomTween.tween_property(self, "scale:x", 1, 1)
	zoomTween.tween_property(self, "scale:y", 1, 1)
	
	fadeTween.tween_callback(after_fade_in)


func after_fade_in() -> void:
	player.global_position = camera.global_position
	player.position.y = 0
	player.global_rotation = camera.global_rotation

	camera_follow = true

func exit_picture() -> void:
	inside_picture = false
	camera_follow = false

	player.global_position -= world_offset
	player.position.y = 0

	var fadeTween = create_tween()
	fadeTween.tween_property(black_bars, "modulate:a", 0, 1)
	fadeTween.tween_callback(after_fade_out)
	
	var zoomTween = create_tween().set_parallel()
	zoomTween.tween_property(self, "position:y", 570, 1)
	zoomTween.tween_property(self, "position:x", 320, 1)
	zoomTween.tween_property(self, "scale:x", 0.5, 1)
	zoomTween.tween_property(self, "scale:y", 0.5, 1)

func after_fade_out() -> void:
	camera.global_position = camera_picture_position
	camera.global_rotation = camera_picture_rotation
	
	
