extends Node3D

@export var maximum_distance_from_origin: float = 3
@export var rotation_on_inspect: Vector3

@onready var original_parent: Node = get_parent()
@onready var original_global_position: Vector3 = global_position
@onready var oiginal_rotation: Vector3 = rotation

var inspecting: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if global_position.distance_to(original_global_position) > maximum_distance_from_origin:
		release()

func interact(player: CharacterBody3D) -> void:
	print("Interacted with " + name)
	
	if not inspecting:
		original_parent.remove_child(self)
		player.inspect_position.add_child(self)
		position = Vector3.ZERO
		rotation = Vector3(deg_to_rad(rotation_on_inspect.x),
						deg_to_rad(rotation_on_inspect.y),
						deg_to_rad(rotation_on_inspect.z))
		inspecting = true
	else:
		release()

func release() -> void:
	get_parent().remove_child(self)
	original_parent.add_child(self)
	global_position = original_global_position
	rotation = oiginal_rotation
	inspecting = false
