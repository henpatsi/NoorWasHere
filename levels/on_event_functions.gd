extends Node

func apply_scene_changes(state: bool, show_nodes, hide_nodes, monitor_areas = null) -> void:
	if state == true:
		for node in show_nodes:
			if is_instance_valid(node):
				node.show()
				disable_child_colliders(node, false)
		for node in hide_nodes:
			if is_instance_valid(node):
				node.hide()
				disable_child_colliders(node, true)
		if monitor_areas:
			for area in monitor_areas:
				if area:
					area.monitoring = true
	else:
		for node in show_nodes:
			if is_instance_valid(node):
				node.hide()
				disable_child_colliders(node, true)
		for node in hide_nodes:
			if is_instance_valid(node):
				node.show()
				disable_child_colliders(node, false)


func disable_child_colliders(node: Node, disabled_state: bool) -> void:
	for child in node.get_children():
		if is_instance_valid(child):
			disable_child_colliders(child, disabled_state)
	if node is CollisionShape3D:
		node.disabled = disabled_state
	if node is CSGBox3D:
		node.use_collision = not disabled_state


func handle_teleport_state(state: bool, prevent_teleport: bool, player: CharacterBody3D) -> void:
	if prevent_teleport:
		player.set_picture_handler_input(state)
