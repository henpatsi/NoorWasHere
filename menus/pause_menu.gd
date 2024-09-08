extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func unpause() -> void:
	print("Unpausing...")
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	queue_free()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		unpause() # TODO fix, repauses instantly


func _on_continue_button_pressed() -> void:
	unpause()
