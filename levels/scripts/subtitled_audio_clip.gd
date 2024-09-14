class_name SubtitleAudioClip
extends Resource

@export var audio_clip: AudioStream
@export var subtitle: String

func _init(p_audio_clip = null, p_subtitle = null):
	audio_clip = p_audio_clip
	subtitle = p_subtitle
