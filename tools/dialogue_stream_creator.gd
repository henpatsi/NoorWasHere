extends Node

@export var audio_clip_dir_path: String = "res://assets/audio/VO/"
@export var subtitles_path: String = "res://assets/audio/subtitles/voice_line_subtitles.csv"
@export var resource_path: String = "res://levels/dialogue_streams/"

var clip_names: Array[String]
var audio_clip_paths = {}
var subtitles = {}

func _on_create_resources_button_pressed() -> void:
	audio_clip_dir_path = standardize_dir_path(audio_clip_dir_path)
	resource_path = standardize_dir_path(resource_path)

	if not parse_audio_clips():
		return
	if not parse_subtitles():
		return
	if not create_resources():
		return
	print("Finished!")


func standardize_dir_path(path: String) -> String:
	if not path.ends_with("/"):
		path += "/"
	return path


func parse_audio_clips() -> bool:
	print("Parsing audio clips")
	var audio_clip_dir = DirAccess.open(audio_clip_dir_path)
	if not audio_clip_dir:
		print("Error opening audio clip dir")
		return false

	audio_clip_dir.list_dir_begin()
	var audio_clip_file_name = audio_clip_dir.get_next()
	while audio_clip_file_name != "":
		if not audio_clip_dir.current_is_dir() and not ".import" in audio_clip_file_name:
			var clip_name = audio_clip_file_name.erase(audio_clip_file_name.find("."), audio_clip_file_name.length())
			clip_names.append(clip_name)
			audio_clip_paths[clip_name] = audio_clip_dir_path + audio_clip_file_name
		audio_clip_file_name = audio_clip_dir.get_next()

	return true


func parse_subtitles() -> bool:
	if subtitles_path:
		print("Parsing subtitles")
		if ".csv" not in subtitles_path:
			print("Subtitles file must be .csv file")
			return false
		var sub_file = FileAccess.open(subtitles_path, FileAccess.READ)
		if not sub_file:
			print("Error opening subtitles file")
			return false

		var line = sub_file.get_csv_line() # Skip header
		line = sub_file.get_csv_line()
		while line[0] != "":
			subtitles[line[0]] = line[1]
			line = sub_file.get_csv_line()
	
	return true


func create_resources() -> bool:
	var resource_dir = DirAccess.open(resource_path)
	if not resource_dir:
		print("Resource dir does not exist")
		return false

	print("Created files:")
	var resource
	for clip_name in clip_names:
		resource = DialogueStream.new()
		resource.audio_stream = load(audio_clip_paths[clip_name])
		resource.subtitle = subtitles[clip_name]
		var error = ResourceSaver.save(resource, resource_path + clip_name + ".tres")
		if error:
			print("Error saving resource ", resource_path, ": ", error_string(error))
		else:
			print(resource_path + clip_name + ".tres")
	
	return true
