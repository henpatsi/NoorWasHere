extends Interactable

@export_category("Settings")
@export var rotation_on_carry: Vector3
@export var carry_position_offset: Vector3
@export var set_requirement: String
@export var follow_speed: float = 1000
@export var max_distance_from_player: float = 3
@export var max_distance_from_original_position: float = 20
@export var mesh: MeshInstance3D

@export_category("Carry audio")
@export var carry_audio_stream_player: AudioStreamPlayer3D
@export var pick_up_audio: AudioStream
@export var put_down_audio: AudioStream

var carrying: bool = false
var dropoff_area: Area3D
var at_correct_position: bool = false

@onready var original_parent: Node = get_parent()
@onready var original_global_position: Vector3 = global_position
@onready var oiginal_rotation: Vector3 = rotation

var material: Material

func _ready() -> void:
	if not verb:
		verb = "Carry"

	if not mesh:
		mesh = get_node_or_null("MeshInstance3D")
	if mesh:
		material = mesh.get_active_material(0)

	super._ready()


func _process(_delta: float) -> void:
	if not carrying:
		return
	
	if global_position.distance_to(player.global_position) > max_distance_from_player:
		reset()
	elif global_position.distance_to(original_global_position) > max_distance_from_original_position:
		reset()


func _physics_process(delta: float) -> void:
	if not carrying:
		return

	var target_position = player.inspect_position.global_position + carry_position_offset
	self.linear_velocity = (target_position - global_position) * delta * follow_speed


func interact(interacting_player: CharacterBody3D) -> Node:
	if at_correct_position:
		player.set_interact_response_message("Object is already at correct position")
		return

	super.interact(interacting_player)

	carry()
	return self


func carry() -> void:
	player.set_picture_handler_input(false)

	self.collision_layer = 2

	get_parent().remove_child(self)
	player.inspect_position.add_child(self)
	position = carry_position_offset
	rotation = Vector3(deg_to_rad(rotation_on_carry.x),
					deg_to_rad(rotation_on_carry.y),
					deg_to_rad(rotation_on_carry.z))
	carrying = true

	if carry_audio_stream_player and pick_up_audio:
		carry_audio_stream_player.stream = pick_up_audio
		carry_audio_stream_player.play()


func release() -> bool:
	if not dropoff_area:
		print("Cannot release here")
		player.set_interact_response_message("Cannot release here")
		return false

	player.set_picture_handler_input(true)

	self.collision_layer = 1

	var new_parent = dropoff_area
	get_parent().remove_child(self)
	new_parent.add_child(self)
	position = Vector3.ZERO
	rotation = Vector3.ZERO
	carrying = false
	
	if carry_audio_stream_player and put_down_audio:
		carry_audio_stream_player.stream = put_down_audio
		carry_audio_stream_player.play()

	player.add_met_picture_requirement(set_requirement)

	material_outside_dropoff()
	
	at_correct_position = true

	return true


# In case player does something unexpected
func reset() -> void:
	get_parent().remove_child(self)
	original_parent.add_child(self)
	global_position = original_global_position
	rotation = oiginal_rotation
	carrying = false
	self.collision_layer = 1

	player.interacting_object = null
	player.set_picture_handler_input(true)

func set_dropoff(area: Area3D) -> void:
	dropoff_area = area
	if dropoff_area:
		player.set_interact_response_message("Release here")
		material_inside_dropoff()
	else:
		material_outside_dropoff()


func material_inside_dropoff() -> void:
	if not mesh or not carrying:
		return

	material.emission_enabled = true
	material.emission = Color.WHITE
	material.emission_energy_multiplier = 0.1

func material_outside_dropoff() -> void:
	if not mesh:
		return
	
	material.emission_enabled = false
