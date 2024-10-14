extends AudioStreamPlayer3D

const FOOTSTEP_GROUPS = ["FootstepDefault", "FootstepWood", "FootstepGrass"]

@export var footstep_duration: float = 0.5
## Played if ground type is not set or for which separate sound effects do not exist
@export var default_footstep_sound_effects: Array[AudioStream]
## Played if ground type is wood
@export var wood_footstep_sound_effects: Array[AudioStream]
## Played if ground type is grass
@export var grass_footstep_sound_effects: Array[AudioStream]

var footstep_sound_effects: Dictionary = {
											FOOTSTEP_GROUPS[0]: default_footstep_sound_effects,
											FOOTSTEP_GROUPS[1]: wood_footstep_sound_effects,
											FOOTSTEP_GROUPS[2]: grass_footstep_sound_effects
										}


var rng = RandomNumberGenerator.new()
var footstep_timer: float = 0.0


func movement_process(delta: float) -> void:
	footstep_timer += delta;
	if footstep_timer < footstep_duration:
		return

	play_random_footstep()
	footstep_timer = 0


func play_random_footstep() -> void:

	stream = default_footstep_sound_effects[rng.randi_range(0, default_footstep_sound_effects.size() - 1)]
	play()
