extends TextureRect

@export var sub_viewport: SubViewport

func _ready():
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	var screenshot = sub_viewport.get_texture()
	texture = screenshot
