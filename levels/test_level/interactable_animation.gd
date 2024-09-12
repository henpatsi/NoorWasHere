extends CSGBox3D

## Name of the key needed to unlock, if blank, already unlocked.
@export var key_name: String
@export var interaction_animations: Array[String]
var animation_index: int = 0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var busy: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func interact(player_inventory: Node) -> void:
	print("Interacted with " + name) 

	if busy:
		print("Interactable busy")
		return
	
	if key_name and not player_inventory.contains_item(key_name):
		print("Locked")
		return

	busy = true

	animation_player.current_animation = interaction_animations[animation_index]
	animation_player.active = true
	
	await get_tree().create_timer(animation_player.current_animation_length).timeout
	
	animation_index += 1
	if animation_index >= interaction_animations.size():
		animation_index = 0

	busy = false
