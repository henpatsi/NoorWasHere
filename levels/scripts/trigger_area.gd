extends Interactable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO fix this hacky crap
	for child in get_tree().root.get_child(1).get_children():
		if child.name == "Pictures":
			picture_manager = child


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return

	print("Area triggered: " + name)

	if one_shot:
		set_deferred("monitoring", false)

	play_dialogue_clips()
	if not changes_wait_for_dialogue:
		apply_scene_changes()
