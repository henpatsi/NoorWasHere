extends Node3D

@export var pauseMenu: PackedScene = preload("res://menus/pause_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		print("Pausing...")
		var pauseMenuInstance = pauseMenu.instantiate()
		add_child(pauseMenuInstance)
