extends Node

@export_category("Settings")
## The time (s) it takes for the picture to move to/from the inspect position.
@export var inspect_speed: float = 10
## The height of the top of the picture when not being inspected.
@export var picture_lower_y: int = 570
## Strength of the lerp to align photo when almost aligned
@export var align_lerp_strength: float = 2

@export_category("Pictures")
@export var pictures: Array[TextureRect]
var picture_index: int = 0
var current_picture: TextureRect

var picture_requirements: Array[String]

var picture_target_position: Vector2 = Vector2(320, 570)
var up_position: bool = false
var inspecting: bool = false
var aligned: bool = false
var inside_picture: bool = false

var player_target_position: Vector3
var player_target_rotation: Vector3

var input_enabled: bool = true
var busy: bool = false

@onready var crosshair: ColorRect = $"../UI/Crosshair"
@onready var interact_label: Label = $"../UI/InteractLabel"

@onready var player: CharacterBody3D = $"../Player"
@onready var head_node: Node3D = $"../Player/HeadNode"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if pictures.size() == 0:
		printerr("Picture handler array is empty.")

	current_picture = pictures[0]
	current_picture.set_active(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not inside_picture:
		outside_picture_process(delta)

func outside_picture_process(delta: float) -> void:
	if current_picture.position.distance_to(picture_target_position) > 1:
		current_picture.position = lerp(current_picture.position, picture_target_position, inspect_speed * delta)
	elif up_position:
		inspecting = true

	if inspecting and current_picture.player_in_correct_position(head_node):
		player.position = lerp(player.position, current_picture.get_local_camera_pos(), align_lerp_strength * delta)
		player.rotation.y = lerpf(player.rotation.y, current_picture.camera.rotation.y, align_lerp_strength * delta)
		head_node.rotation.x = lerpf(head_node.rotation.x, current_picture.camera.rotation.x, align_lerp_strength * delta)
		aligned = true
		interact_label.text = "Enter picture"


func _input(event: InputEvent) -> void:
	if not input_enabled:
		return
	
	if event.is_action_pressed("inspect_picture"):
		if inside_picture:
			current_picture.exit_picture(player)
			inside_picture = false

		up_position = not up_position
		if not up_position:
			picture_target_position.y = picture_lower_y
			inspecting = false
		else:
			picture_target_position.y = current_picture.size.y / 2
			if up_position:
				crosshair.hide()
			else:
				crosshair.show()

	if event.is_action_pressed("next_picture"):
		print("Swapping to next picture")
		set_active_picture(picture_index + 1)
	
	if event.is_action_pressed("previous_picture"):
		print("Swapping to previous picture")
		set_active_picture(picture_index - 1)
	
	if event.is_action_pressed("enter_picture"):
		print("Trying to enter picture")
		if not inspecting:
			print ("Not inspecting a picture")
			return
		if not aligned:
			print ("Not aligned to picture")
			return
		if inside_picture:
			print ("Already inside picture")
			return
		current_picture.enter_picture(player, head_node)
		inside_picture = true
		busy = true


func add_picture(picture: TextureRect) -> void:
	pictures.append(picture)
	set_active_picture(pictures.size() - 1)


func set_active_picture(index: int) -> void:
	if up_position:
		print("Put down picture to swap")
		return
	if pictures.size() == 1:
		print("No pictures to swap to")
		return

	if index == pictures.size():
		index = 0
	if index == -1:
		index = pictures.size() - 1
	
	current_picture.set_active(false)

	current_picture = pictures[index]
	current_picture.set_active(true)

	picture_index = index
