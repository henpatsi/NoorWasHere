extends Node

@export var items: Array[String]
@export var pictures: Array[TextureRect]
@export var past_pictures: Array[TextureRect]

func add_item(item: String) -> void:
	items.append(item)

func add_picture(array: Array[TextureRect], picture: TextureRect) -> void:
	array.append(picture)
	picture.show()

func get_pictures() -> Array[TextureRect]:
	return pictures

func get_past_pictures() -> Array[TextureRect]:
	return past_pictures

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
