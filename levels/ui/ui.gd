extends Control

@export_range(0, 1) var subtitle_ratio: float = 1
@export_range(0, 1) var interact_text_ratio: float = 0.75
@export_range(0, 1) var interact_response_text_ratio: float = 0.5

@onready var subtitle_label: Label = $SubtitleLabel
@onready var interact_label: Label = $InteractLabel
@onready var interact_response_label: Label = $InteractResponseLabel
@onready var crosshair: ColorRect = $Crosshair

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func update() -> void:
	crosshair.color.a = GlobalSettings.crosshair_opacity
	crosshair.size.x = GlobalSettings.crosshair_size
	crosshair.size.y = GlobalSettings.crosshair_size
	crosshair.position.x = size.x / 2 - crosshair.size.x / 2
	crosshair.position.y = size.y / 2 - crosshair.size.y / 2
	
	subtitle_label.label_settings.font_size = GlobalSettings.text_size * subtitle_ratio
	interact_label.label_settings.font_size = GlobalSettings.text_size * interact_text_ratio
	interact_response_label.label_settings.font_size = GlobalSettings.text_size * interact_response_text_ratio
