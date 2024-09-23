extends Interactable

@export_category("Settings")
@export var picture_handler: Node
@export var picture: TextureRect


func _ready() -> void:
	if not verb:
		verb = "Pick up"

	super._ready()


func interact(player: CharacterBody3D) -> Node:
	super.interact(player)

	picture_handler.add_picture(picture)

	queue_free()
	
	return null
