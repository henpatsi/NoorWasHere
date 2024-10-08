extends TextureRect

@export var sub_viewport: SubViewport
@export var picture: TextureRect

func _ready():
	pass

func take_screenshot() -> void:
	for node in picture.nodes_to_show:
		if is_instance_valid(node):
			node.show()
	for node in picture.nodes_to_hide:
		if is_instance_valid(node):
			node.hide()

	await get_tree().create_timer(0.1).timeout

	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	var screenshot = sub_viewport.get_texture()
	texture = screenshot
	
	# Wait to allow screenshot to be taken before hiding
	await get_tree().create_timer(0.1).timeout
	
	for node in picture.nodes_to_show:
		if is_instance_valid(node):
			node.hide()
	for node in picture.nodes_to_hide:
		if is_instance_valid(node):
			node.show()
