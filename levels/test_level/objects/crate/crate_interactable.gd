extends Node3D

@onready var lid: MeshInstance3D = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func interact() -> bool:
	lid.rotate(Vector3.RIGHT, deg_to_rad(90))
	return true
