extends Node3D

@export var player: CharacterBody3D
@export var positions: Array[Node3D]

var index: int = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_teleport"):
		if positions.size() == 0:
			print("No debug positions set")
			return

		player.global_position = positions[index].global_position
		index += 1
		if index == positions.size():
			index = 0
