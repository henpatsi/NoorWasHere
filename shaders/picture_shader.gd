extends ColorRect

@export var enter_speed: float = 1
@export var maximum_speed: float = 0.5
@export var grain_amount_inside: float = 0.02
@export var grain_amount_outside: float = 0.01

func _ready() -> void:
	set_shader_speed(0)

func on_enter_picture() -> void:
	var tween = create_tween().parallel()
	tween.tween_method(set_shader_speed, 0.0, maximum_speed, enter_speed)
	tween.tween_method(set_shader_grain_amount, grain_amount_outside, grain_amount_inside, enter_speed)

func on_exit_picture() -> void:
	var tween = create_tween().parallel()
	tween.tween_method(set_shader_speed, maximum_speed, 0.0, enter_speed)
	tween.tween_method(set_shader_grain_amount, grain_amount_inside, grain_amount_outside, enter_speed)

func set_shader_speed(value: float) -> void:
	material.set_shader_parameter("speed", value);

func set_shader_grain_amount(value: float) -> void:
	material.set_shader_parameter("grain_amount", value);
