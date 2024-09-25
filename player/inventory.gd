extends Node

@export var items: Array[String]
@export var pictures: Array[TextureRect]

func add_item(item: String) -> void:
	items.append(item)

func add_picture(picture: TextureRect) -> void:
	pictures.append(picture)
	picture.show()

func get_pictures() -> Array[TextureRect]:
	return pictures

func get_picture(index: int) -> TextureRect:
	if pictures.size() == 0:
		return null
	while index < 0:
		index += pictures.size()
	if index >= pictures.size():
		index %= pictures.size()
	return pictures[index]


func contains_item(query: String) -> bool:
	for item in items:
		if item == query:
			return true
	return false
