extends Node

## The maximum resolution for a texture
@export var max_texture_resolution: int = 512
## The path to the texture directory to resize
@export var texture_directory: String = "res://assets/textures/"
## Setting to true will also resize any textures in any child directories
@export var search_child_directories: bool = true

var resized_images_print: Array[String]

func _on_resize_textures_button_pressed() -> void:
	resize_directory_textures(texture_directory)
	
	print("Resized images:")
	for resized_image_print in resized_images_print:
		print(resized_image_print)

func resize_directory_textures(dir_path: String) -> void:
	if not dir_path.ends_with("/"): # Standardize input
		dir_path += "/"

	var dir = DirAccess.open(dir_path)
	if not dir:
		print("Error opening texture dir: ", dir_path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = dir_path + file_name
		if dir.current_is_dir() and search_child_directories:
			resize_directory_textures(file_path)
		elif file_name.to_lower().ends_with(".png"):
			resize_image(file_path)
		file_name = dir.get_next()
	dir.list_dir_end()


func resize_image(image_path: String) -> void:
	var image = Image.load_from_file(image_path)
	if not image:
		print("Failed to load image: ", image_path)
		return

	if image.get_width() <= max_texture_resolution and image.get_height() <= max_texture_resolution:
		return

	var aspect_ratio = float(image.get_width()) / float(image.get_height())
	var new_width = min(image.get_width(), max_texture_resolution)
	var new_height = min(image.get_height(), max_texture_resolution)
	
	if new_width > new_height:
		new_height = new_width / aspect_ratio
	else:
		new_width = new_height * aspect_ratio

	image.resize(new_width, new_height)
	image.save_png(image_path)
	resized_images_print.append(image_path + " (" + str(image.get_width()) + " x " + str(image.get_height()) + ")")
