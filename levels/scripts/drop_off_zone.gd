extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	print(body.name + " entered")
	if body.has_method("set_dropoff"):
		body.set_dropoff(self)


func _on_body_exited(body: Node3D) -> void:
	print(body.name + " exited")
	if body.has_method("set_dropoff"):
		body.set_dropoff(null)
