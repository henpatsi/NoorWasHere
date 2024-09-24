extends Interactable

@export_category("Settings")
@export var picture: TextureRect


func _ready() -> void:
	if not verb:
		verb = "Pick up"

	super._ready()


func interact(interacting_player: CharacterBody3D) -> Node:
	super.interact(interacting_player)

	player.on_picture_picked_up(picture)

	queue_free()
	
	return null
