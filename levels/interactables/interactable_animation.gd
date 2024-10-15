extends Interactable

@export_category("Settings")
## Name of the key needed to unlock, if blank, already unlocked.
@export var key_name: String
## A list of animation names. Plays the first animation on first interact, second on second, etc, and loops.
@export var interaction_animations: Array[String]

var animation_index: int = 0
var animation_player: AnimationPlayer = null

var animation_player_search_paths: Array[String] = ["AnimationPlayer", "../AnimationPlayer"]

var busy: bool = false

func _ready() -> void:
	super._ready()
	
	for path in animation_player_search_paths:
		animation_player = get_node_or_null(path)
		if animation_player:
			break

	if not animation_player:
		print(self.name, " is missing an animation player!")

func interact(interacting_player: CharacterBody3D) -> Node:
	if busy:
		print("Interactable busy")
		return null
	
	if key_name and not interacting_player.inventory.contains_item(key_name):
		print("Locked")
		player.set_interact_response_message("Locked")
		return null

	busy = true
	
	super.interact(interacting_player)
	play_animation()
	
	return null

func play_animation() -> void:
	animation_player.current_animation = interaction_animations[animation_index]
	animation_player.active = true
	
	animation_index += 1
	if animation_index >= interaction_animations.size():
		animation_index = 0

	await get_tree().create_timer(animation_player.current_animation_length).timeout

	busy = false
