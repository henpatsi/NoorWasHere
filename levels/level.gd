extends Node3D

@export var pauseMenu: PackedScene = preload("res://menus/pause_menu.tscn")
@export var env_past := preload("res://assets/WorldEnvironments/Env_Past.tres")
@export var env_present := preload("res://assets/WorldEnvironments/Env_Present.tres")
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var directional_light_3d: DirectionalLight3D = $DirectionalLightPresent

@export var picture_screenshots: Array[TextureRect]
@export var black_screen: ColorRect

var paused: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if not paused:
			print("Pausing...")
			var pauseMenuInstance = pauseMenu.instantiate()
			add_child(pauseMenuInstance)
		paused = not paused

	if event.is_action_pressed("mouse_left_click"):
		if not paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func load_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)
