extends TextureRect

@onready var player: CharacterBody3D = $"../../../Player"
@onready var player_camera: Camera3D = $"../../../Player/HeadNode/Camera3D"

@onready var black_bars: ColorRect = $"../../../BlackBars"
@onready var black_bars2: ColorRect = $"../../../BlackBars2"

@onready var shutter_audio_player: AudioStreamPlayer3D = $"../../../ShutterAudioPlayer"

@export var camera: Camera3D
@onready var camera_picture_position: Vector3 = camera.global_position
@onready var camera_picture_rotation: Vector3 = camera.global_rotation

@export var world: Node3D

var inspecting: bool = false
var inside_picture: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if inside_picture:
		camera.global_position = player_camera.global_position
		camera.global_rotation = player_camera.global_rotation

func toggle_inspecting() -> void:
	inspecting = not inspecting
	var tween = create_tween()
	if inside_picture:
		exit_picture()
	elif inspecting:
		tween.tween_property(self, "position:y", 180, 1)
	else:
		tween.tween_property(self, "position:y", 570, 1)

	

func enter_picture() -> void:
	if not inspecting:
		print("Must be inspecting to enter picture")
		return
	if inside_picture:
		print("Already inside picture")
		return

	shutter_audio_player.play()

	black_bars2.show()
	black_bars.show()

	player.global_position = camera.global_position
	player.position.y = 0
	player.global_rotation = camera.global_rotation

	inside_picture = true
	
	await get_tree().create_timer(0.3).timeout
	black_bars2.hide()
	await get_tree().create_timer(0.3).timeout
	
	var zoomTween = create_tween().set_parallel()
	zoomTween.tween_property(self, "position:y", 0, 1)
	zoomTween.tween_property(self, "position:x", 0, 1)
	zoomTween.tween_property(self, "scale:x", 1, 1)
	zoomTween.tween_property(self, "scale:y", 1, 1)


func exit_picture() -> void:
	inside_picture = false

	shutter_audio_player.play()

	black_bars2.show()
	black_bars.hide()

	player.global_position -= world.global_position
	player.position.y = 0

	camera.global_position = camera_picture_position
	camera.global_rotation = camera_picture_rotation
	
	scale = Vector2(0.5, 0.5)
	position = Vector2(320, 180)
	
	await get_tree().create_timer(0.3).timeout
	black_bars2.hide()
	await get_tree().create_timer(0.3).timeout

	var tween = create_tween()
	tween.tween_property(self, "position:y", 570, 1)
