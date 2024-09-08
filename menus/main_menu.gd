extends Control

var startScene: PackedScene = preload("res://levels/level1.tscn")
var settingsScene: PackedScene = preload("res://menus/settings_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(startScene)

func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_packed(settingsScene)

func _on_exit_button_pressed() -> void:
	get_tree().quit()
