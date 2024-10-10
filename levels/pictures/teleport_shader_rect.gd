extends ColorRect

var enter_speed: float = 1
var maximum_intensity: float = 2
var maximum_speed: float = 1

func _ready() -> void:
	material.set_shader_parameter("intensity", 0);
	material.set_shader_parameter("speed", 0);

func on_enter_picture() -> void:
	var intensityTween = create_tween()
	intensityTween.tween_method(set_shader_intensity, 0.0, maximum_intensity, enter_speed / 2)
	intensityTween.tween_method(set_shader_intensity, maximum_intensity, 0.0, enter_speed / 2)
	
	var speedTween = create_tween()
	speedTween.tween_method(set_shader_speed, 0.0, maximum_speed, enter_speed / 2)
	speedTween.tween_method(set_shader_speed, maximum_speed, 0.0, enter_speed / 2)

func on_exit_picture() -> void:
	on_enter_picture()

func set_shader_intensity(value: float) -> void:
	material.set_shader_parameter("intensity", value);

func set_shader_speed(value: float) -> void:
	material.set_shader_parameter("speed", value);
