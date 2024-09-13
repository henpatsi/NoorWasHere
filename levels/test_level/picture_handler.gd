extends Node

@export_category("Settings")
## The time (s) it takes for the picture to move to/from the inspect position.
@export var inspect_speed: float = 10
## The height of the top of the picture when not being inspected.
@export var picture_lower_y: int = 570

@export_category("Pictures")
@export var pictures: Array[TextureRect]
var picture_index: int = 0
var current_picture: TextureRect

var enabled: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if pictures.size() == 0:
		printerr("Picture handler array is empty.")

	current_picture = pictures[picture_index]
	current_picture.set_active(true, self)
	current_picture.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if not enabled:
		return
	
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

func add_picture(picture: TextureRect) -> void:
	pictures.append(picture)
	set_active_picture(pictures.size() - 1)
	current_picture.toggle_inspecting()

func set_active_picture(index: int) -> void:
	if current_picture.up_position:
		print("Put down picture to swap")
		return
	if pictures.size() == 1:
		print("No pictures to swap to")
		return

	if index == pictures.size():
		index = 0
	if index == -1:
		index = pictures.size() - 1
	
	current_picture.set_active(false, self)

	current_picture = pictures[index]
	current_picture.set_active(true, self)

	picture_index = index
