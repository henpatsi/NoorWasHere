class_name Interactable
extends Node3D

@export_category("Settings")
@export var item_name: String
## If true, only be interacted with once
@export var one_shot: bool = false
## If true, cannot use picture input until audio played
@export var prevent_teleport: bool = false
## Lable to which the response to the interaction (e.g. "locked", "successful") is written
@export var interact_response_label: Label

@export_category("Audio")
## If true, only play audio once (does not do anything if one_shot is also true)
@export var audio_one_shot: bool = false
## Audio stream player that plays all audio clips
@export var audio_stream_player: AudioStreamPlayer3D
## Label to which subtitles are written
@export var subtitle_label: Label
## Array of audio clips, played in order
@export var audio_clips: Array[AudioStream]
## Array of subtitles, shown in order with the same index audio clip
@export var subtitles: Array[String]
var audio_index = 0
var audio_played: bool = false

@export_category("Scene changes")
## Nodes that will be shown once the animation has played
@export var nodes_to_show: Array[Node]
## Nodes that will be hidden once the animation has played
@export var nodes_to_hide: Array[Node]
## Area3D nodes that should start monitoring
@export var start_monitoring_list: Array[Area3D]
## Waits until all audio clips have been played until making the listed changes
@export var wait_for_audio: bool = false

var picture_manager: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO fix this hacky crap
	for child in get_tree().root.get_child(1).get_children():
		if child.name == "Pictures":
			picture_manager = child
	
	if not is_in_group("Interactable"):
		printerr("Interactable " + name + " is not in the \"Interactable\" group")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func interact(_player: CharacterBody3D) -> void:
	print("Interacted with " + name)

	if one_shot:
		remove_from_group("Interactable")

	handle_teleport_state(false)

	play_audio_clips()
	if not wait_for_audio:
		apply_scene_changes()


func handle_teleport_state(state: bool) -> void:
	if prevent_teleport:
		picture_manager.set_input_state(state)


func play_audio_clips() -> void:
	if not audio_stream_player or audio_clips.size() == 0:
		handle_teleport_state(true)
		return
	if audio_one_shot and audio_played:
		handle_teleport_state(true)
		return
	audio_played = true
	while audio_index < audio_clips.size():
		audio_stream_player.stream = audio_clips[audio_index]
		audio_stream_player.play()
		if subtitle_label and subtitles[audio_index]:
			subtitle_label.text = subtitles[audio_index]
		await get_tree().create_timer(audio_clips[audio_index].get_length()).timeout
		audio_index += 1
	audio_index = 0
	if subtitle_label:
		subtitle_label.text = ""

	if wait_for_audio:
		apply_scene_changes()

	handle_teleport_state(true)


func apply_scene_changes() -> void:
	for node in nodes_to_show:
		if is_instance_valid(node):
			node.show()
			set_child_collider_states(node, false)
	for node in nodes_to_hide:
		if is_instance_valid(node):
			node.hide()
			set_child_collider_states(node, true)
	for area in start_monitoring_list:
		area.monitoring = true


func set_child_collider_states(node: Node, disabled_state: bool) -> void:
	for child in node.get_children():
		if is_instance_valid(child):
			set_child_collider_states(child, disabled_state)
	if node is CollisionShape3D:
		node.disabled = disabled_state
	if node is CSGBox3D:
		node.use_collision = not disabled_state
