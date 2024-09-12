extends Area3D

@export_category("Settings")
@export var one_shot: bool = false
var triggered: bool = false
var wait_triggered: bool = false

@export_category("Audio")
@export var audio_stream_player: AudioStreamPlayer3D
@export var audio_stream: AudioStream
@export var override_playing: bool = false

@export_category("Activate")
@export var activate_wait_for_audio: bool = false
@export var nodes_to_activate: Array[Node]
@export var nodes_to_deactivate: Array[Node]
@export var nodes_to_show: Array[Node]
@export var nodes_to_hide: Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if triggered and one_shot:
		return

	if not body.is_in_group("Player"):
		return
	
	print("Area triggered")
	wait_triggered = false

	audio_trigger()
	activate_trigger()

	if one_shot:
		queue_free()


func audio_trigger() -> void:
	# Play audio if set and conditions met
	if audio_stream_player and audio_stream:
		if override_playing or audio_stream_player.playing == false:
			audio_stream_player.stream = audio_stream
			audio_stream_player.play()
			

func activate_trigger() -> void:
	if activate_wait_for_audio and audio_stream_player and audio_stream:
		await get_tree().create_timer(audio_stream.get_length()).timeout

	for node in nodes_to_activate:
		node.set_process(true)
	for node in nodes_to_deactivate:
		node.set_process(false)
	for node in nodes_to_show:
		node.show()
	for node in nodes_to_hide:
		node.hide()
