extends Control

var mainMenuScene: PackedScene = load("res://menus/main_menu.tscn")

@export var mouse_sensitivity_value_label: Label
@export var mouse_sensitivity_slider: HSlider
@export var volume_value_label: Label
@export var volume_slider: HSlider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	set_starting_values()


func set_starting_values():
	mouse_sensitivity_value_label.text = str(GlobalSettings.mouse_sensitivity_modifier).pad_decimals(1)
	mouse_sensitivity_slider.value = GlobalSettings.mouse_sensitivity_modifier
	volume_value_label.text = str(round((GlobalSettings.volume_db + 60) / 60 * 100))
	volume_slider.value = GlobalSettings.volume_db


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


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(mainMenuScene)


func _on_mouse_sensitivity_slider_value_changed(value: float) -> void:
	mouse_sensitivity_value_label.text = str(value).pad_decimals(1)
	GlobalSettings.mouse_sensitivity_modifier = value


func _on_volume_slider_value_changed(value: float) -> void:
	volume_value_label.text = str(round((value + 60) / 60 * 100))
	GlobalSettings.volume_db = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
