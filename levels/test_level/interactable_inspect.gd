extends Node3D

@export_category("Settings")
@export var maximum_distance_from_origin: float = 3
@export var rotation_on_inspect: Vector3

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
## Waits until all audio clips have been played until making the listed changes
@export var wait_for_audio: bool = false

@onready var original_parent: Node = get_parent()
@onready var original_global_position: Vector3 = global_position
@onready var oiginal_rotation: Vector3 = rotation

var inspecting: bool = false
var busy: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if global_position.distance_to(original_global_position) > maximum_distance_from_origin:
		release()

func interact(player: CharacterBody3D) -> void:
	print("Interacted with " + name)
	
	if busy:
		print("Interactable busy")
		return
	
	busy = true
	
	if not inspecting:
		original_parent.remove_child(self)
		player.inspect_position.add_child(self)
		position = Vector3.ZERO
		rotation = Vector3(deg_to_rad(rotation_on_inspect.x),
						deg_to_rad(rotation_on_inspect.y),
						deg_to_rad(rotation_on_inspect.z))
		inspecting = true
		
		play_audio_clips()
		if not wait_for_audio:
			apply_scene_changes()
	else:
		release()

	busy = false

func release() -> void:
	get_parent().remove_child(self)
	original_parent.add_child(self)
	global_position = original_global_position
	rotation = oiginal_rotation
	inspecting = false


func play_audio_clips() -> void:
	if not audio_stream_player or audio_clips.size() == 0:
		return
	if audio_one_shot and audio_played:
		return
	audio_played = true
	while audio_index < audio_clips.size():
		audio_stream_player.stream = audio_clips[audio_index]
		audio_stream_player.play()
		await get_tree().create_timer(audio_clips[audio_index].get_length()).timeout
		audio_index += 1
	audio_index = 0
	
	if wait_for_audio:
		apply_scene_changes()

func apply_scene_changes() -> void:
	for node in nodes_to_show:
		if is_instance_valid(node):
			node.show()
			set_child_collider_states(node, false)
	for node in nodes_to_hide:
		if is_instance_valid(node):
			node.hide()
			set_child_collider_states(node, true)


func set_child_collider_states(node: Node, disabled_state: bool) -> void:
	for child in node.get_children():
		if is_instance_valid(child):
			set_child_collider_states(child, disabled_state)
	if node is CollisionShape3D:
		node.disabled = disabled_state
	if node is CSGBox3D:
		node.use_collision = not disabled_state
