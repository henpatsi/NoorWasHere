extends Node3D

@export_category("Settings")
## Name of the key needed to unlock, if blank, already unlocked.
@export var key_name: String
@export var interaction_animations: Array[String]
@export var interact_response_label: Label
@export var one_shot: bool = false
@export var prevent_teleport: bool = false

@export_category("Audio")
@export var audio_one_shot: bool = false
@export var audio_stream_player: AudioStreamPlayer3D
@export var subtitle_label: Label
@export var audio_clips: Array[AudioStream]
@export var subtitles: Array[String]
# @export var override_playing: bool = false
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

var animation_index: int = 0
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var busy: bool = false

var picture_manager: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO fix this hacky crap
	for child in get_tree().root.get_child(1).get_children():
		if child.name == "Pictures":
			picture_manager = child


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func interact(player: CharacterBody3D) -> void:
	print("Interacted with " + name) 

	if busy:
		print("Interactable busy")
		return
	
	if key_name and not player.inventory.contains_item(key_name):
		print("Locked")
		if interact_response_label:
			interact_response_label.change_text("Locked")
		return

	busy = true
	
	if prevent_teleport:
		picture_manager.set_input_state(false)
	
	if one_shot:
		remove_from_group("Interactable")

	animation_player.current_animation = interaction_animations[animation_index]
	animation_player.active = true
	
	animation_index += 1
	if animation_index >= interaction_animations.size():
		animation_index = 0

	play_audio_clips()

	if not wait_for_audio:
		apply_scene_changes()

	await get_tree().create_timer(animation_player.current_animation_length).timeout

	busy = false


func play_audio_clips() -> void:
	if not audio_stream_player or audio_clips.size() == 0:
		if prevent_teleport:
			picture_manager.set_input_state(true)
		return
	if audio_one_shot and audio_played:
		if prevent_teleport:
			picture_manager.set_input_state(true)
		return
	audio_played = true
	while audio_index < audio_clips.size():
		audio_stream_player.stream = audio_clips[audio_index]
		audio_stream_player.play()
		if subtitle_label:
			subtitle_label.text = subtitles[audio_index]
		await get_tree().create_timer(audio_clips[audio_index].get_length()).timeout
		audio_index += 1
	audio_index = 0
	if subtitle_label:
		subtitle_label.text = ""
	
	if wait_for_audio:
		apply_scene_changes()
	
	if prevent_teleport:
		picture_manager.set_input_state(true)


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
