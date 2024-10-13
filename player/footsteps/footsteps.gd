extends AudioStreamPlayer3D

var rng = RandomNumberGenerator.new()

@export var footstep_duration: float = 0.5
@export var footstep_sound_effects: Array[AudioStream]

var footstep_timer: float = 0.0

func movement_process(delta: float) -> void:
	footstep_timer += delta;
	if footstep_timer < footstep_duration:
		return

	play_random_footstep()
	footstep_timer = 0


func play_random_footstep() -> void:
	stream = footstep_sound_effects[rng.randi_range(0, footstep_sound_effects.size() - 1)]
	play()
