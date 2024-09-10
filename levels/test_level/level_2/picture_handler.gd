extends Node

@export var pictures: Array[MeshInstance3D]
@onready var currentPicture: MeshInstance3D = pictures[0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("swap_places"):
		if !currentPicture:
			print("No picture to swap with")
			return
		currentPicture.swap_places()
		pictures.erase(currentPicture)
		currentPicture.queue_free()

	if event.is_action_pressed("inspect_picture"):
		if !currentPicture:
			print("No picture to inspect")
			return
		currentPicture.inspecting = !currentPicture.inspecting
