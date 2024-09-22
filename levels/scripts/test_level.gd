extends Node3D

var pauseMenu: PackedScene = preload("res://menus/pause_menu.tscn")

var paused: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


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


func set_past_environment() -> void:
	print("Setting environment to past")
	pass
	
func set_present_environment() -> void:
	print("Setting environment to present")
	pass


func load_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)
