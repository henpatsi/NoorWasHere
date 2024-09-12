extends Node3D

@export var item_name: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func interact(player: CharacterBody3D) -> void:
	print("Interacted with " + name)
	
	player.inventory.add_item(item_name)

	queue_free()
