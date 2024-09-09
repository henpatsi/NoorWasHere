extends Camera3D

@export var playerHead: Node3D

var positionOffset: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position.y = playerHead.global_position.y
	positionOffset = global_position - playerHead.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position = playerHead.global_position + positionOffset
	global_rotation = playerHead.global_rotation
