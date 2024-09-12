extends Node

@export var pictures: Array[TextureRect]
@onready var currentPicture: TextureRect = pictures[0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if currentPicture:
		currentPicture.active_picture = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inspect_picture"):
		if !currentPicture:
			print("No picture to inspect")
			return
		currentPicture.toggle_inspecting()
