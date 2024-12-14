extends Interactable

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return

	print("Area triggered: " + name)

	player = body

	if one_shot:
		set_deferred("monitoring", false)

	if not dialogue_triggered and dialogue_clips.size() > 0:
		start_dialogue_clips()
	else:
		OnEventFunctions.apply_scene_changes(true, nodes_to_show, nodes_to_hide, start_monitoring_list)
