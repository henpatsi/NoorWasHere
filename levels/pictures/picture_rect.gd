extends TextureRect

@export var lower_position: Vector2 = Vector2(320, 570)
@export var exit_picture_position: Vector2 = Vector2(320, 800)
@export var hide_position: Vector2 = Vector2(700, 1000)
var upper_position: Vector2
var target_position: Vector2

var is_up: bool = false
@export var move_speed: float = 10
var at_target_position: bool = false

@export var picture_resize_time: float = 1
@export var picture_shader: ColorRect

var viewport: SubViewport

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	upper_position = Vector2(get_viewport().get_visible_rect().size / 2) - (self.size / 2)

	position = lower_position
	target_position = lower_position
	
	var viewport_path = get_texture().get_viewport_path_in_scene() as String
	var viewport_local_path = get_tree().current_scene.get_path() as String
	viewport_local_path = viewport_local_path.path_join(viewport_path)
	viewport = get_node(viewport_local_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
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

	await resize(exit_picture_position, Vector2(640, 360), picture_resize_time)
	
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

	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	await get_tree().create_timer(0.1).timeout
	viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
