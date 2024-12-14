extends Interactable

@export_category("Settings")
@export var picture: Node
@export var destroy_on_pickup: bool = true

@onready var collider: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	if not verb:
		verb = "Pick up"

	super._ready()


func interact(interacting_player: CharacterBody3D) -> Node:
	super.interact(interacting_player)

	player.on_picture_picked_up(self)

	if destroy_on_pickup:
		queue_free()
	else:
		hide()
		collider.disabled = true

	return null
