extends Control

@export var enabled: bool = true

# Delay before new text is displayed.
@export var default_text_swap_delay: float = 1

@export var text1: String = "Press 'F' to raise / lower photo"
@export var text2: String = "Move (WASD and mouse) to align the photo with the scene"
@export var text3: String = "Press 'left mouse button' to enter the photo"
@export var text4: String = "When you are done exploring the photo, press 'R' to exit"
@export var text5: String = "Use 'Q' and 'E' to cycle through the photos"

@onready var tutorial_label: Label = $TutorialLabel

@onready var picture_handler = %PictureHandler
@onready var inventory = %Inventory

var busy: bool = false
var text_index = 0

var entered_picture: bool = false
var pictures_added: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not enabled:
		return

	switch_text(text1, 1)

func _process(_delta: float) -> void:
	if not enabled:
		return

	if text_index <= 1 and picture_handler.inspecting:
		switch_text(text2, 2)

	if text_index <= 2 and picture_handler.aligned:
		switch_text(text3, 3)
	
	if text_index <= 3 and picture_handler.picture_depth == 1:
		entered_picture = true
		if not pictures_added:
			pictures_added = true
			inventory.add_tutorial_pictures()
		if picture_handler.input_blockers == 0:
			switch_text(text4, 4)
		else:
			switch_text("", 3)

	if text_index <= 4 and picture_handler.picture_depth == 0 and entered_picture:
		switch_text(text5, 5)

	if text_index == 5 and picture_handler.picture_index != 0:
		switch_text("", 6)


func switch_text(new_text: String, new_index: int, delay: float = default_text_swap_delay) -> void:
	if busy:
		return

	busy = true

	await get_tree().create_timer(delay).timeout

	tutorial_label.text = new_text
	text_index = new_index

	tutorial_label.show()

	busy = false


func set_text(new_text: String) -> void:
	tutorial_label.text = new_text
	tutorial_label.show()


func _on_crouch_tutorial_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		set_text("Hold left control to crouch")


func _on_crouch_tutorial_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		set_text("")
