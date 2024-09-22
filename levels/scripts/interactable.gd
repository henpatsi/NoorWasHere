class_name Interactable
extends Node3D

@export_category("Settings")
## Name of the item, shown when prompted to interact, use editor name if not set
@export var item_name: String
## If true, can only be interacted with once
@export var one_shot: bool = false
## Lable to which the response to the interaction (e.g. "locked", "successful") is written
@export var interact_response_label: Label

@export_category("Audio")
## Audio stream player that plays interact audio
@export var interact_stream_player: AudioStreamPlayer3D
## Interact audio stream
@export var interact_audio_stream: AudioStream
## Audio stream player that plays dialogue audio
@export var dialogue_stream_player: AudioStreamPlayer3D
## Array of dialogue clips, played in order
@export var dialogue_clips: Array[Resource]
## Label to which subtitles are written
@export var subtitle_label: Label
## If true, cannot use picture input until dialogue played
@export var prevent_teleport: bool = true
## Delay (s) before the dialogue is started
@export var dialogue_delay: float = 0.0

var dialogue_index = 0
var dialogue_played: bool = false

@export_category("Scene changes")
## Nodes that will be shown once the animation has played
@export var nodes_to_show: Array[Node]
## Nodes that will be hidden once the animation has played
@export var nodes_to_hide: Array[Node]
## Area3D nodes that should start monitoring
@export var start_monitoring_list: Array[Area3D]
## Waits until all dialogue clips have been played until making the listed changes
@export var changes_wait_for_dialogue: bool = false

var picture_manager: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO fix this hacky crap
	for child in get_tree().root.get_child(1).get_children():
		if child.name == "Pictures":
			picture_manager = child
	
	if not is_in_group("Interactable"):
		printerr("Interactable " + name + " is not in the \"Interactable\" group")
	
	if not item_name:
		item_name = name


func interact(_player: CharacterBody3D) -> void:
	print("Interacted with " + name)

	if one_shot:
		remove_from_group("Interactable")

	play_dialogue_clips()
	if not changes_wait_for_dialogue:
		apply_scene_changes()


func handle_teleport_state(state: bool) -> void:
	if prevent_teleport:
		picture_manager.set_input_state(state)


func play_dialogue_clips() -> void:
	if not dialogue_stream_player or dialogue_clips.size() == 0:
		return
	if dialogue_played:
		return
		
	dialogue_played = true
	handle_teleport_state(false)
	
	if dialogue_delay > 0:
		await get_tree().create_timer(dialogue_delay).timeout

	while dialogue_index < dialogue_clips.size():
		dialogue_stream_player.stream = dialogue_clips[dialogue_index].audio_stream
		dialogue_stream_player.play()
		if subtitle_label:
			subtitle_label.text = dialogue_clips[dialogue_index].subtitle
		await get_tree().create_timer(dialogue_clips[dialogue_index].audio_stream.get_length()).timeout
		dialogue_index += 1

	if subtitle_label:
		subtitle_label.text = ""

	if changes_wait_for_dialogue:
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
