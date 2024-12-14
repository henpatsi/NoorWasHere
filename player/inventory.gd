extends Node

@export var items: Array[String]
@export var starting_pictures: Array[Node]
@export var pictures_after_tutorial: Array[Node]
@export var max_depth = 2

var pictures = {}

func _ready() -> void:
	for i in range(max_depth + 1):
		var arr: Array[Node] = []
		pictures[i] = arr

	for picture in starting_pictures:
		pictures[0].append(picture)

func add_item(item: String) -> void:
	items.append(item)

func add_picture(array: Array[Node], picture: Node) -> void:
	array.append(picture)

func add_tutorial_pictures() -> void:
	for picture in pictures_after_tutorial:
		add_picture(pictures[0], picture)

func clear_pictures(depth: int) -> void:
	pictures[depth].clear()

func get_pictures(depth: int):
	return pictures[depth]

func get_picture(array: Array[Node], index: int) -> Node:
	if array.size() == 0:
		return null
	return array[get_index_in_range(array, index)]

func get_index_in_range(array: Array[Node], index: int) -> int:
	while index < 0:
		index += array.size()
	if index >= array.size():
		index %= array.size()
	return index


func contains_item(query: String) -> bool:
	for item in items:
		if item == query:
			return true
	return false
