extends MeshInstance3D

@onready var picture_position_down: Node3D = $"../../../Player/HeadNode/PicturePositionDown"
@onready var picture_position_up: Node3D = $"../../../Player/HeadNode/PicturePositionUp"

@export var original_objects: Node3D
@export var replacement_objects: Node3D

var inspecting: bool = false

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
	
func swap_places() -> void:
	var temppos: Vector3 = replacement_objects.global_position
	replacement_objects.global_position = original_objects.global_position
	original_objects.global_position = temppos
