extends Interactable

@export_category("Settings")
@export var rotation_on_carry: Vector3
@export var picture_handler: Node
@export var set_requirement: String

@export_category("Carry audio")
@export var carry_audio_stream_player: AudioStreamPlayer3D
@export var pick_up_audio: AudioStream
@export var put_down_audio: AudioStream

var carrying: bool = false
var dropoff_area: Area3D


func interact(player: CharacterBody3D) -> Node:

	super.interact(player)

	if not carrying:
		get_parent().remove_child(self)
		player.inspect_position.add_child(self)
		position = Vector3(0, -0.5, -0.5)
		rotation = Vector3(deg_to_rad(rotation_on_carry.x),
						deg_to_rad(rotation_on_carry.y),
						deg_to_rad(rotation_on_carry.z))
		carrying = true
		
		if carry_audio_stream_player and pick_up_audio:
			carry_audio_stream_player.stream = pick_up_audio
			carry_audio_stream_player.play()
		return self
	else:
		release()
		return null

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
	rotation = Vector3.ZERO
	carrying = false
	
	if carry_audio_stream_player and put_down_audio:
		carry_audio_stream_player.stream = put_down_audio
		carry_audio_stream_player.play()

	picture_handler.picture_requirements_met.append(set_requirement)

func set_dropoff(area: Area3D) -> void:
	dropoff_area = area
	interact_response_label.change_text("Release here")
