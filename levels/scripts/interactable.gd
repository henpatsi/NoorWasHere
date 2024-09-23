class_name Interactable
extends Node3D

@export_category("Settings")
## Name of the item, shown when prompted to interact, use editor name if not set.
@export var item_name: String
## Verb for the interaction, by default "Interact with", default overriden in child classes.
@export var verb: String
## If true, can only be interacted with once. Dialogue will ever only be played once.
@export var one_shot: bool = true
## Lable to which the response to the interaction (e.g. "locked", "successful") is written.
@export var interact_response_label: Label

@export_category("Audio")
## Audio stream player that plays interact audio.
@export var interact_stream_player: AudioStreamPlayer3D
## Interact audio stream.
@export var interact_audio_stream: AudioStream
## Audio stream player that plays dialogue audio.
@export var dialogue_stream_player: AudioStreamPlayer3D
## Array of dialogue clips, played in order.
@export var dialogue_clips: Array[Resource]
## Label to which subtitles are written.
@export var subtitle_label: Label
## If true, cannot use picture input until dialogue played.
@export var prevent_teleport: bool = true
## Delay (s) before the dialogue is started.
@export var dialogue_delay: float = 0.0

var dialogue_index = 0
var dialogue_playing: bool = false
var dialogue_triggered: bool = false

@export_category("Scene changes")
## Nodes that will be shown once the animation has played.
@export var nodes_to_show: Array[Node]
## Nodes that will be hidden once the animation has played.
@export var nodes_to_hide: Array[Node]
## Area3D nodes that should start monitoring.
@export var start_monitoring_list: Array[Area3D]
## Waits until all dialogue clips have been played until making the listed changes.
@export var changes_wait_for_dialogue: bool = true

@onready var picture_manager: Node = %PictureManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not picture_manager:
		printerr("Picture manager was not found")
	
	if not item_name:
		item_name = name
	
	if not verb:
		verb = "Interact with"


func _process(_delta) -> void:
	dialogue_process()

# Called by player when interacting, returns self if this blocks other interactions
func interact(_player: CharacterBody3D) -> Node:
	print("Interacted with " + name)

	if one_shot:
		remove_from_group("Interactable")

	if interact_stream_player and interact_audio_stream:
		interact_stream_player.stream = interact_audio_stream
		interact_stream_player.play()

	if not dialogue_triggered and dialogue_stream_player and dialogue_clips.size() > 0:
		start_dialogue_clips()

	if not changes_wait_for_dialogue:
		apply_scene_changes()

	return null

func handle_teleport_state(state: bool) -> void:
	if prevent_teleport:
		picture_manager.set_input_state(state)


func start_dialogue_clips() -> void:
	dialogue_triggered = true
	handle_teleport_state(false)
	
	if dialogue_delay > 0:
		await get_tree().create_timer(dialogue_delay).timeout

	dialogue_playing = true


func dialogue_process() -> void:
	if not dialogue_playing or dialogue_stream_player.playing:
		return

	if dialogue_index == dialogue_clips.size():
		dialogue_playing = false
		if subtitle_label:
			subtitle_label.text = ""
		if changes_wait_for_dialogue:
			apply_scene_changes()
		handle_teleport_state(true)
		return

	dialogue_stream_player.stream = dialogue_clips[dialogue_index].audio_stream
	dialogue_stream_player.play()

	if subtitle_label:
		subtitle_label.text = dialogue_clips[dialogue_index].subtitle

	dialogue_index += 1



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
