extends Interactable

@export_category("Settings")
@export var rotation_on_inspect: Vector3
@export var inspect_position_offset: Vector3

@onready var original_parent: Node = get_parent()
@onready var original_global_position: Vector3 = global_position
@onready var oiginal_rotation: Vector3 = rotation

var inspecting: bool = false


func _ready() -> void:
	if not verb:
		verb = "Inspect"

	super._ready()


func interact(player: CharacterBody3D) -> Node:
	super.interact(player)

	if not inspecting:
		inspect(player)
		return self
	else:
		release()
		return null


func inspect(player: CharacterBody3D) -> void:
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
