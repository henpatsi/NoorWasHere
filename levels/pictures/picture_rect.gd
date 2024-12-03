extends TextureRect

@export var lower_position: Vector2 = Vector2(320, 570)
var upper_position: Vector2

var is_up: bool = false
var move_speed: float = 10
var at_target_position: bool = false

@export var picture_resize_time: float = 1
@export var picture_shader: ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	upper_position = Vector2(get_viewport().get_visible_rect().size / 2) - (self.size / 2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if at_target_position:
		return

	var target_position: Vector2 = upper_position if is_up else lower_position
	position = position.lerp(target_position, move_speed * delta)
	if position.distance_to(target_position) < 0.1:
		at_target_position = true


func toggle_up() -> void:
	at_target_position = false
	is_up = !is_up


func set_up(state: bool) -> void:
	at_target_position = false
	is_up = state


func enter_picture() -> void:
	print("Rect enter picture")

	picture_shader.on_enter_picture()

	await resize(Vector2(0, 0), Vector2(1280, 720), picture_resize_time)


func exit_picture() -> void:
	print("Rect exit picture")

	picture_shader.on_exit_picture()

	resize(lower_position, Vector2(640, 360), picture_resize_time)


func resize(target_position: Vector2, target_size: Vector2, speed: float) -> void:
	var zoomTween = create_tween().set_parallel()
	zoomTween.tween_property(self, "position:x", target_position.x, picture_resize_time)
	zoomTween.tween_property(self, "position:y", target_position.y, picture_resize_time)
	zoomTween.tween_property(self, "size:x", target_size.x, picture_resize_time)
	zoomTween.tween_property(self, "size:y", target_size.y, picture_resize_time)

	await get_tree().create_timer(picture_resize_time).timeout
