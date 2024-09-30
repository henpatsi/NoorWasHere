extends Control

@export var audio_clip_dir_path: String = "res://assets/audio/VO/"
@export var subtitles_path: String = "res://assets/audio/subtitles/voice_line_subtitles.csv"
@export var resource_path: String = "res://resources/"

func _on_create_resources_button_pressed() -> void:
	var audio_clip_dir = DirAccess.open(audio_clip_dir_path)
	if not audio_clip_dir:
		print("Error opening audio clip dir")
		return

	print("Parsing audio clips")
	var clip_names: Array[String]
	var audio_clip_paths = {}
	audio_clip_dir.list_dir_begin()
	var audio_clip_file_name = audio_clip_dir.get_next()
	while audio_clip_file_name != "":
		if not audio_clip_dir.current_is_dir() and not ".import" in audio_clip_file_name:
			var clip_name = audio_clip_file_name.erase(audio_clip_file_name.find("."), audio_clip_file_name.length())
			clip_names.append(clip_name)
			audio_clip_paths[clip_name] = audio_clip_dir_path + audio_clip_file_name
		audio_clip_file_name = audio_clip_dir.get_next()

	var subtitles = {}
	if subtitles_path:
		print("Parsing subtitles")
		if ".csv" not in subtitles_path:
			print("Subtitles file must be .csv file")
			return
		var sub_file = FileAccess.open(subtitles_path, FileAccess.READ)
		if not sub_file:
			print("Error opening subtitles file")
			return

		var line = sub_file.get_csv_line() # Skip header
		line = sub_file.get_csv_line()
		while line[0] != "":
			subtitles[line[0]] = line[1]
			line = sub_file.get_csv_line()

	print("Created files:")
	var resource
	for clip_name in clip_names:
		resource = DialogueStream.new()
		resource.audio_stream = load(audio_clip_paths[clip_name])
		resource.subtitle = subtitles[clip_name]
		ResourceSaver.save(resource, resource_path + clip_name + ".tres")
		print(resource_path + clip_name + ".tres")
	
	print("Finished!")
