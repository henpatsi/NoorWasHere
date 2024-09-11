extends Node

@export var pictures: Array[TextureRect]
@onready var currentPicture: TextureRect = pictures[0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	currentPicture.check_player_position()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("swap_places"):
		if !currentPicture:
			print("No picture to swap with")
			return
		currentPicture.enter_picture()

	if event.is_action_pressed("inspect_picture"):
		if !currentPicture:
			print("No picture to inspect")
			return
		currentPicture.toggle_inspecting()
