extends Interactable

@export_category("Settings")
## Variable name to add to player inventory
@export var variable_name: String


func _ready() -> void:
	if not verb:
		verb = "Pick up"

	super._ready()


func interact(player: CharacterBody3D) -> Node:
	super.interact(player)

	player.inventory.add_item(variable_name)

	if interact_response_label:
		interact_response_label.change_text("Picked up " + variable_name)

	queue_free()

	return null
