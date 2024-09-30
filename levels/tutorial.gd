extends Control

@export var text1: String = "Press 'F' to raise / lower photo"
@export var text2: String = "Move (WASD and mouse) to align the photo with the scene"
@export var text3: String = "Press 'left mouse button' to enter the photo"
@export var text4: String = "When you are done exploring the photo, press 'R' to exit"
@export var text5: String = "Use 'Q' and 'E' to cycle through the photos"

@onready var tutorial_label: Label = $TutorialLabel

@onready var picture_handler = %PictureHandler
@onready var inventory = %Inventory

var text_index = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tutorial_label.text = text1
	tutorial_label.show()

func _process(delta: float) -> void:
	if text_index == 1 and picture_handler.aligned:
		switch_text(text3)
		text_index += 1

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inspect_picture") and text_index == 0:
		switch_text(text2)
		text_index += 1
	
	if event.is_action_pressed("enter_picture") and text_index == 2:
		switch_text(text4)
		text_index += 1

	if event.is_action_pressed("exit_picture") and text_index == 3:
		inventory.add_tutorial_pictures()
		switch_text(text5)
		text_index += 1

	if (event.is_action_pressed("next_picture") or event.is_action_pressed("previous_picture")) and text_index == 4:
		switch_text("")
		text_index += 1

func switch_text(new_text: String) -> void:
	tutorial_label.text = new_text
