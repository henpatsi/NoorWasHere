extends Interactable

@export_category("Settings")
@export var maximum_distance_from_origin: float = 3
@export var rotation_on_inspect: Vector3
@export var inspect_position_offset: Vector3

@onready var original_parent: Node = get_parent()
@onready var original_global_position: Vector3 = global_position
@onready var oiginal_rotation: Vector3 = rotation

var inspecting: bool = false

var player: CharacterBody3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if global_position.distance_to(original_global_position) > maximum_distance_from_origin:
		release()


func interact(player: CharacterBody3D) -> Node:
	self.player = player
	super.interact(player)

	if not inspecting:
		inspect()
		return self
	else:
		release()
		return null


func inspect() -> void:
	original_parent.remove_child(self)
	player.inspect_position.add_child(self)
	position = inspect_position_offset
	rotation = Vector3(deg_to_rad(rotation_on_inspect.x),
					deg_to_rad(rotation_on_inspect.y),
					deg_to_rad(rotation_on_inspect.z))
	inspecting = true


func release() -> void:
	get_parent().remove_child(self)
	original_parent.add_child(self)
	global_position = original_global_position
	rotation = oiginal_rotation
	inspecting = false
	player.interacting_object = null
