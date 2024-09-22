extends Area3D

@export var end_sequence: Control

func _on_body_entered(body: Node3D) -> void:
	end_sequence.play_end_sequence()
