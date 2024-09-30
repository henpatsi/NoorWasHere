extends Control

@export var player: CharacterBody3D
@export var picture_screenshots: Array[TextureRect]
@export var show_times: Array[float]
@export var player_dialogues_ASP: AudioStreamPlayer3D

@export var level: Node
@export var end_menu_path: String = "res://menus/end_menu.tscn"

@onready var color_rect: ColorRect = $ColorRect
@onready var label: Label = $Label

@onready var picture_handler = %PictureHandler

func play_end_sequence() -> void:
	picture_handler.set_input_state(false)
	picture_handler.process_mode = Node.PROCESS_MODE_DISABLED
	#player.process_mode = Node.PROCESS_MODE_DISABLED

	var i: int = 0
	for screenshot in picture_screenshots:
		screenshot.get_parent().remove_child(screenshot)
		add_child(screenshot)
		screenshot.position = Vector2(0, 0)
		screenshot.size = Vector2(1280, 720)
		screenshot.show()
		await get_tree().create_timer(show_times[i]).timeout
		i += 1
		screenshot.hide()
	
	#level.load_scene(end_menu_path)
	color_rect.show()
	label.show()
