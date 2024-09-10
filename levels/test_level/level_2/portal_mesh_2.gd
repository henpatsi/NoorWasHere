extends MeshInstance3D

@onready var portal_camera: Camera3D = $"../SubViewport/PortalCamera"
@onready var picture_position_up: Node3D = $"../../Player/HeadNode/PicturePositionUp"
@onready var picture_position_down: Node3D = $"../../Player/HeadNode/PicturePositionDown"

@onready var player: CharacterBody3D = $"../../Player"

var following: bool = true
var inspecting: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not following:
		return
	
	if not inspecting:
		global_position = picture_position_down.global_position
	else:
		global_position = picture_position_up.global_position
	global_rotation = picture_position_down.global_rotation
	
func swap_places() -> void:
	portal_camera.swap_places()
	queue_free()
