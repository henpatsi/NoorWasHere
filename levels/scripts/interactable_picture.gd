extends Interactable

@export_category("Settings")
@export var picture_handler: Node
@export var picture: TextureRect


func interact(player: CharacterBody3D) -> Node:
	super.interact(player)

	picture_handler.add_picture(picture)

	queue_free()
	
	return null
