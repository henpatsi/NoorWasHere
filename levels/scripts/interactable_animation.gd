extends Interactable

@export_category("Settings")
## Name of the key needed to unlock, if blank, already unlocked.
@export var key_name: String
## A list of animation names. Plays the first animation on first interact, second on second, etc, and loops.
@export var interaction_animations: Array[String]

var animation_index: int = 0
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var busy: bool = false


func interact(player: CharacterBody3D) -> void:
	if busy:
		print("Interactable busy")
		return
	
	if key_name and not player.inventory.contains_item(key_name):
		print("Locked")
		if interact_response_label:
			interact_response_label.change_text("Locked")
		return

	busy = true
	
	super.interact(player)

	animation_player.current_animation = interaction_animations[animation_index]
	animation_player.active = true
	
	animation_index += 1
	if animation_index >= interaction_animations.size():
		animation_index = 0

	await get_tree().create_timer(animation_player.current_animation_length).timeout

	busy = false
