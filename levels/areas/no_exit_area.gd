extends Area3D


func _on_body_entered(body: Node3D) -> void:
	print("Entered by ", body.name)
	if body.has_method("on_no_exit_area_entered"):
		body.on_no_exit_area_entered()
