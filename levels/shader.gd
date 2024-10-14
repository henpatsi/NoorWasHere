extends ColorRect

@onready var world_environment: WorldEnvironment = $"../WorldEnvironment"
var ENV_PAST = preload("res://assets/WorldEnvironments/Env_Past.tres")
var ENV_PRESENT = preload("res://assets/WorldEnvironments/Env_Present.tres")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shader"):
		if world_environment.environment == ENV_PRESENT:
			world_environment.environment = ENV_PAST
			visible = false
		else:
			world_environment.environment = ENV_PRESENT
			visible = true
