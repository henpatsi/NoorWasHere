extends Area3D

class SubtitledAudioClip:
	var audioClip: AudioStream
	var subtitle: String

@export_category("Settings")
@export var one_shot: bool = false

@export_category("Audio")
@export var audio_stream_player: AudioStreamPlayer3D
@export var subtitle_label: Label
@export var audio_clips: Array[SubtitledAudioClip]
@export var override_playing: bool = false
var audio_index = -1

# @export_category("Activate")
# @export var activate_wait_for_audio: bool = false
# @export var nodes_to_activate: Array[Node]
# @export var nodes_to_deactivate: Array[Node]
# @export var nodes_to_show: Array[Node]
# @export var nodes_to_hide: Array[Node]

var active: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not active:
		return
	
	if audio_stream_player and audio_clips.size() > 0:
		handle_audio_clip()
	
	if not active and one_shot:
		queue_free()


func _on_body_entered(body: Node3D) -> void:
	if active:
		return

	if not body.is_in_group("Player"):
		return
	
	print("Area triggered")
	active = true
	audio_index = -1


func handle_audio_clip() -> void:
	if audio_stream_player.playing:
		return

	audio_index += 1
	if audio_index >= audio_clips.size():
		active = false
		return
	
	audio_stream_player.stream = audio_clips[audio_index].audioClip
	audio_stream_player.play()

	# TODO subtitles

# func activate_trigger() -> void:
# 	for node in nodes_to_activate:
# 		node.set_process(true)
# 	for node in nodes_to_deactivate:
# 		node.set_process(false)
# 	for node in nodes_to_show:
# 		node.show()
# 	for node in nodes_to_hide:
# 		node.hide()
