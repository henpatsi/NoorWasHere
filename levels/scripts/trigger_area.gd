extends Interactable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not picture_manager:
		printerr("Picture manager was not found")


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return

	print("Area triggered: " + name)

	if one_shot:
		set_deferred("monitoring", false)

	if not dialogue_triggered and dialogue_stream_player and dialogue_clips.size() > 0:
		start_dialogue_clips()

	if not changes_wait_for_dialogue:
		apply_scene_changes()
