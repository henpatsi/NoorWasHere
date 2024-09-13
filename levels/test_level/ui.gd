extends Control

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
	
	subtitle_label.label_settings.font_size = GlobalSettings.text_size
	interact_label.label_settings.font_size = GlobalSettings.text_size / 2
	interact_response_label.label_settings.font_size = GlobalSettings.text_size / 2
