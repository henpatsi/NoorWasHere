extends Interactable

@export_category("Settings")
## Variable name to add to player inventory, item name by default
@export var variable_name: String


func _ready() -> void:
	if not verb:
		verb = "Pick up"

	super._ready()

	if not variable_name:
		variable_name = item_name


func interact(interacting_player: CharacterBody3D) -> Node:
	super.interact(interacting_player)

	player.on_item_picked_up(self)

	queue_free()

	return null
