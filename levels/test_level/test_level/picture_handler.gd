extends Node

@export var pictures: Array[TextureRect]
var picture_index: int = 0
var current_picture: TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	printerr("Picture handler array is empty.")

	current_picture = pictures[picture_index]
	current_picture.active_picture = true
	current_picture.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inspect_picture"):
		if !current_picture:
			print("No picture to inspect")
			return
		current_picture.toggle_inspecting()

	if event.is_action_pressed("next_picture"):
		print("Swapping to next picture")
		set_active_picture(picture_index + 1)
	
	if event.is_action_pressed("previous_picture"):
		print("Swapping to previous picture")
		set_active_picture(picture_index - 1)


func set_active_picture(index: int) -> void:
	if current_picture.up_position:
		print("Put down picture to swap")
		return

	if index == pictures.size():
		index = 0
	if index == -1:
		index = pictures.size() - 1
	
	current_picture.active_picture = false
	current_picture.hide()

	current_picture = pictures[index]
	current_picture.active_picture = true
	current_picture.show()

	picture_index = index
