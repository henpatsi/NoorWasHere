extends Node

@export var items: Array[String]
@export var starting_pictures: Array[TextureRect]
@export var max_depth = 2

var pictures = {}

func _ready() -> void:
	for i in range(max_depth + 1):
		var rect_array: Array[TextureRect] = []
		pictures[i] = rect_array

	for picture in starting_pictures:
		pictures[0].append(picture)

func add_item(item: String) -> void:
	items.append(item)

func add_picture(array: Array[TextureRect], picture: TextureRect) -> void:
	array.append(picture)
	picture.show()

func clear_pictures(depth: int) -> void:
	pictures[depth].clear()

func get_pictures(depth: int):
	return pictures[depth]

func get_picture(array: Array[TextureRect], index: int) -> TextureRect:
	if array.size() == 0:
		return null
	while index < 0:
		index += array.size()
	if index >= array.size():
		index %= array.size()
	return array[index]


func contains_item(query: String) -> bool:
	for item in items:
		if item == query:
			return true
	return false
