extends MeshInstance3D

@onready var player: CharacterBody3D = $"../../../Player"
@onready var player_camera: Camera3D = $"../../../Player/HeadNode/Camera3D"

@onready var picture_position_down: Node3D = $"../../../Player/HeadNode/PicturePositionDown"
@onready var picture_position_up: Node3D = $"../../../Player/HeadNode/PicturePositionUp"

@export var camera: Camera3D
@onready var camera_picture_position: Vector3 = camera.global_position
@onready var camera_picture_rotation: Vector3 = camera.global_rotation

@export var world_offset: Vector3

var inspecting: bool = false
var inside_picture: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not inspecting:
		global_position = picture_position_down.global_position
	else:
		global_position = picture_position_up.global_position
	global_rotation = picture_position_down.global_rotation
	
	if inside_picture:
		camera.global_position = player_camera.global_position
		camera.global_rotation = player_camera.global_rotation
		

func toggle_inspecting() -> void:
	inspecting = not inspecting
	if inside_picture:
		exit_picture()

func enter_picture() -> void:
	if inside_picture:
			print("Already inside picture")
			return
	player.global_position = camera.global_position
	player.position.y = 0
	player.global_rotation = camera.global_rotation
	inside_picture = true

func exit_picture() -> void:
	player.global_position -= world_offset
	player.position.y = 0
	camera.global_position = camera_picture_position
	camera.global_rotation = camera_picture_rotation
	inside_picture = false
