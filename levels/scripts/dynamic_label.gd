extends Label

@export var fade_time: float = 1.0

var timer: float = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer <= 0:
		return
	
	timer -= delta
	
	if timer <= 0:
		text = ""


func change_text(new_text: String) -> void:
	text = new_text
	timer = fade_time
