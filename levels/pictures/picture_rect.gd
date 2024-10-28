extends TextureRect

@export var lower_position: Vector2 = Vector2(320, 570)
var upper_position: Vector2

var is_up: bool = false

@export var picture_resize_time: float = 0.5

@export var picture_shader: ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	upper_position = Vector2(get_viewport().get_visible_rect().size / 2) - (self.size / 2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("crouch"):
		enter_picture()
	if event.is_action("enter_picture"):
		exit_picture()


func enter_picture() -> void:
	print("Enter")

	picture_shader.on_enter_picture()

	await resize(Vector2(0, 0), Vector2(1280, 720), picture_resize_time)


func exit_picture() -> void:
	print("Exit")

	picture_shader.on_exit_picture()

	await resize(lower_position, Vector2(640, 360), picture_resize_time)


func resize(target_position: Vector2, target_size: Vector2, speed: float) -> void:
	var zoomTween = create_tween().set_parallel()
	zoomTween.tween_property(self, "position:x", target_position.x, picture_resize_time)
	zoomTween.tween_property(self, "position:y", target_position.y, picture_resize_time)
	zoomTween.tween_property(self, "size:x", target_size.x, picture_resize_time)
	zoomTween.tween_property(self, "size:y", target_size.y, picture_resize_time)

	await get_tree().create_timer(picture_resize_time).timeout
