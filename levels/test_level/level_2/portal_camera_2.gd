extends Camera3D

@export var originalObjects: Node3D
@export var replacementObjects: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func swap_places() -> void:
	var temppos = replacementObjects.global_position
	replacementObjects.global_position = originalObjects.global_position
	originalObjects.global_position = temppos
