extends Control

var mainMenuScene: PackedScene = load("res://menus/main_menu.tscn")

@export var mouse_sensitivity_value_label: Label
@export var mouse_sensitivity_slider: HSlider
@export var volume_value_label: Label
@export var volume_slider: HSlider

<<<<<<< HEAD
=======
@export var crosshair_opacity_value_label: Label
@export var crosshair_opacity_slider: HSlider
@export var crosshair_size_value_label: Label
@export var crosshair_size_slider: HSlider

>>>>>>> parent of 93d547d (text size setting, still not working perfect)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_starting_values()


func set_starting_values():
	mouse_sensitivity_value_label.text = str(GlobalSettings.mouse_sensitivity_modifier).pad_decimals(1)
	mouse_sensitivity_slider.value = GlobalSettings.mouse_sensitivity_modifier
	volume_value_label.text = str(round((GlobalSettings.volume_db + 60) / 60 * 100))
	volume_slider.value = GlobalSettings.volume_db
<<<<<<< HEAD

=======
	
	crosshair_opacity_value_label.text = str(round(GlobalSettings.crosshair_opacity * 100))
	crosshair_opacity_slider.value = GlobalSettings.crosshair_opacity
	crosshair_size_value_label.text = str(GlobalSettings.crosshair_size)
	crosshair_size_slider.value = GlobalSettings.crosshair_size
>>>>>>> parent of 93d547d (text size setting, still not working perfect)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_mouse_sensitivity_slider_value_changed(value: float) -> void:
	mouse_sensitivity_value_label.text = str(value).pad_decimals(1)
	GlobalSettings.mouse_sensitivity_modifier = value


func _on_volume_slider_value_changed(value: float) -> void:
	volume_value_label.text = str(round((value + 60) / 60 * 100))
	GlobalSettings.volume_db = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)


<<<<<<< HEAD
=======
func _on_crosshair_opacity_slider_value_changed(value: float) -> void:
	crosshair_opacity_value_label.text = str(round(value * 100))
	GlobalSettings.crosshair_opacity = value


func _on_crosshair_size_slider_value_changed(value: float) -> void:
	crosshair_size_value_label.text = str(value)
	GlobalSettings.crosshair_size = value


>>>>>>> parent of 93d547d (text size setting, still not working perfect)
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_packed(mainMenuScene)
