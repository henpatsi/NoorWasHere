extends Node

@export var items: Array[String]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func add_item(item: String) -> void:
	items.append(item)


func contains_item(query: String) -> bool:
	for item in items:
		if item == query:
			return true
	return false
