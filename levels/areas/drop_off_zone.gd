extends Area3D

func _on_body_entered(body: Node3D) -> void:
	print(body.name + " entered")
	if body.has_method("set_dropoff"):
		body.set_dropoff(self)


func _on_body_exited(body: Node3D) -> void:
	print(body.name + " exited")
	if body.has_method("set_dropoff"):
		body.set_dropoff(null)
