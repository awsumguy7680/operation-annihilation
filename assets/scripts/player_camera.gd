extends Camera2D

var zoomed_in = true

var current_vehicle = null

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_I and event.is_pressed() and zoomed_in == true:
			zoom = Vector2(0.1, 0.1)
			zoomed_in = false
		elif event.keycode == KEY_I and event.is_pressed() and zoomed_in == false:
			zoom = Vector2(0.3, 0.3)
			zoomed_in = true

func _on_main_scene_child_entered_tree(new_child: Node):
	if new_child is CharacterBody2D:
		current_vehicle = new_child
		reparent(current_vehicle, false)

func _on_main_scene_child_exiting_tree(removed_child: Node):
	if removed_child is CharacterBody2D:
		if current_vehicle != null:
			reparent($"..")
			current_vehicle = null
