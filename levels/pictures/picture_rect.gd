extends TextureRect

@export var lower_position: Vector2 = Vector2(320, 570)
@export var hide_position: Vector2 = Vector2(700, 1000)
var upper_position: Vector2
var target_position: Vector2

var is_up: bool = false
@export var move_speed: float = 20
var at_target_position: bool = false

@export var picture_resize_time: float = 1
@export var picture_shader: ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	upper_position = Vector2(get_viewport().get_visible_rect().size / 2) - (self.size / 2)
	target_position = lower_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if at_target_position:
		return

	position = position.lerp(target_position, move_speed * delta)
	if position.distance_to(target_position) < 0.1:
		at_target_position = true


func toggle_up() -> void:
	at_target_position = false
	is_up = !is_up
	target_position = upper_position if is_up else lower_position


func set_up(state: bool) -> void:
	at_target_position = false
	is_up = state
	target_position = upper_position if is_up else lower_position


func enter_picture() -> void:
	print("Rect enter picture")

	picture_shader.on_enter_picture()

	await resize(Vector2(0, 0), Vector2(1280, 720), picture_resize_time)


func exit_picture() -> void:
	print("Rect exit picture")

	picture_shader.on_exit_picture()

	await resize(lower_position, Vector2(640, 360), picture_resize_time)
	
	set_up(false)


func resize(resize_target_position: Vector2, resize_target_size: Vector2, speed: float) -> void:
	var zoomTween = create_tween().set_parallel()
	zoomTween.tween_property(self, "position:x", resize_target_position.x, speed)
	zoomTween.tween_property(self, "position:y", resize_target_position.y, speed)
	zoomTween.tween_property(self, "size:x", resize_target_size.x, speed)
	zoomTween.tween_property(self, "size:y", resize_target_size.y, speed)

	await get_tree().create_timer(speed).timeout


func hide_picture() -> void:
	at_target_position = false
	target_position = hide_position


func show_picture() -> void:
	at_target_position = false
	target_position = upper_position if is_up else lower_position
