extends Node3D

@export var rotation_on_carry: Vector3
@export var interact_response_label: Label

@export var picture_handler: Node
@export var set_requirement: String

var carrying: bool = false
var dropoff_area: Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func interact(player: CharacterBody3D) -> void:
	print("Interacted with " + name)
	
	if not carrying:
		get_parent().remove_child(self)
		player.inspect_position.add_child(self)
		position = Vector3.ZERO
		rotation = Vector3(deg_to_rad(rotation_on_carry.x),
						deg_to_rad(rotation_on_carry.y),
						deg_to_rad(rotation_on_carry.z))
		carrying = true
	else:
		release()

func release() -> void:
	if not dropoff_area:
		print("Cannot release here")
		if interact_response_label:
			interact_response_label.change_text("Cannot release here")
		return

	var new_parent = dropoff_area
	get_parent().remove_child(self)
	new_parent.add_child(self)
	position = Vector3.ZERO
	carrying = false

	picture_handler.picture_requirements.append(set_requirement)

func set_dropoff(area: Area3D) -> void:
	dropoff_area = area
