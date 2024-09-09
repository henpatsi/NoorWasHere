extends MeshInstance3D

@export var playerPortalPosition: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position = playerPortalPosition.global_position
	global_rotation = playerPortalPosition.global_rotation
	
