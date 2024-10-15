extends ColorRect

@onready var world_environment: WorldEnvironment = $"../WorldEnvironment"
var ENV_PAST = preload("res://assets/WorldEnvironments/Env_Past.tres")
var ENV_PRESENT = preload("res://assets/WorldEnvironments/Env_Present.tres")
@onready var shadow_catcher: MeshInstance3D = $"../ShadowCatcher"

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shader"):
		if world_environment.environment == ENV_PRESENT:
			world_environment.environment = ENV_PAST
			visible = true
			shadow_catcher.visible = true
		else:
			world_environment.environment = ENV_PRESENT
			visible = false
			shadow_catcher.visible = false
