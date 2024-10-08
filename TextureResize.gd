extends Node

# Define the target resolution
const MAX_TEXTURE_SIZE = 512

func _ready():
	# Path to the directory where your textures are stored.
	var texture_directory = "res://assets/AtmosphericHouse/Textures/Clean/Fireplace/"
	
	# Get all PNG files, including from subfolders.
	var texture_files = get_png_files_recursive(texture_directory)

	# Loop through each texture file.
	for texture_file in texture_files:
		# Load the texture.
		var image = load_image(texture_file)
		
		if image:
			# Check if the image exceeds the max size.
			if image.get_width() > MAX_TEXTURE_SIZE or image.get_height() > MAX_TEXTURE_SIZE:
				# Resize the image while keeping the aspect ratio.
				resize_image(image, texture_file)

func get_png_files_recursive(dir_path: String) -> Array:
	# Get all PNG files in the directory and subdirectories using DirAccess.
	var dir = DirAccess.open(dir_path)
	var png_files = []
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				# If the current file is a directory, recurse into it.
				if file_name != "." and file_name != "..":  # Ignore special directories.
					var subfolder_path = dir_path + "/" + file_name
					png_files += get_png_files_recursive(subfolder_path)
			elif file_name.ends_with(".png"):
				# If it's a PNG file, add it to the list.
				png_files.append(dir_path + "/" + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Failed to open directory: ", dir_path)
	
	return png_files

func load_image(file_path: String) -> Image:
	# Load the PNG file into an Image object.
	var image = Image.new()
	var error = image.load(file_path)
	
	if error == OK:
		return image
	else:
		print("Failed to load image: ", file_path)
		return null

func resize_image(image: Image, file_path: String):
	# Calculate the new size while maintaining the aspect ratio.
	var aspect_ratio = float(image.get_width()) / float(image.get_height())
	
	var new_width = min(image.get_width(), MAX_TEXTURE_SIZE)
	var new_height = min(image.get_height(), MAX_TEXTURE_SIZE)
	
	if new_width > new_height:
		new_height = new_width / aspect_ratio
	else:
		new_width = new_height * aspect_ratio

	# Resize the image.
	image.resize(new_width, new_height)

	# Save the resized image back to its original file.
	image.save_png(file_path)
	print("Resized and saved image:", file_path)
