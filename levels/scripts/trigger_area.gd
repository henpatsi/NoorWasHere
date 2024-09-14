extends Area3D

@export_category("Settings")
@export var one_shot: bool = false
@export var prevent_teleport: bool = false
@export var activate_delay: float = 0.0

@export_category("Audio")
@export var audio_one_shot: bool = false
@export var audio_stream_player: AudioStreamPlayer3D
@export var subtitle_label: Label
@export var audio_clips: Array[AudioStream]
@export var subtitles: Array[String]
# @export var override_playing: bool = false
var audio_index = 0
var audio_played: bool = false

@export_category("Activate")
@export var start_monitoring_list: Array[Area3D]
## Waits until all audio clips have been played until making the listed changes
@export var wait_for_audio: bool = false

@onready var picture_manager: Node

var active: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO fix this hacky crap
	for child in get_tree().root.get_child(1).get_children():
		if child.name == "Pictures":
			picture_manager = child


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	

func _on_body_entered(body: Node3D) -> void:
	if active:
		return

	if not body.is_in_group("Player"):
		return

	print("Area triggered")
	active = true

	if prevent_teleport:
		picture_manager.input_enabled = false

	if activate_delay > 0:
		await get_tree().create_timer(activate_delay).timeout
	
	play_audio_clips()
	if not wait_for_audio:
		apply_scene_changes()
	
	if one_shot:
		monitoring = false


func play_audio_clips() -> void:
	if not audio_stream_player or audio_clips.size() == 0:
		picture_manager.input_enabled = true
		active = false
		return
	if audio_one_shot and audio_played:
		picture_manager.input_enabled = true
		active = false
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

	picture_manager.input_enabled = true
	active = false


func apply_scene_changes() -> void:
	for area in start_monitoring_list:
		area.monitoring = true
