extends Node3D

@export var pauseMenu: PackedScene = preload("res://menus/pause_menu.tscn")
@export var env_past := preload("res://assets/WorldEnvironments/Env_Past.tres")
@export var env_present := preload("res://assets/WorldEnvironments/Env_Present.tres")
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var directional_light_3d: DirectionalLight3D = $DirectionalLight3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	set_past_environment()
	await get_tree().create_timer(1).timeout
	set_present_environment()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		print("Pausing...")
		var pauseMenuInstance = pauseMenu.instantiate()
		add_child(pauseMenuInstance)

	if event.is_action_pressed("mouse_left_click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func set_past_environment() -> void:
	print("Setting environment to past")
	world_environment.environment = env_past
	directional_light_3d.light_energy = 0
	
func set_present_environment() -> void:
	print("Setting environment to present")
	world_environment.environment = env_present
	directional_light_3d.light_energy = 1
