extends Camera2D

var zoom_spd = 0.01
var max_zoom = Vector2(0.3, 0.3)
var min_zoom = Vector2(0.05, 0.05)

var current_vehicle = null

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("zoom_in"):
		zoom += Vector2(zoom_spd, zoom_spd)
		zoom = clamp(zoom, min_zoom, max_zoom)
	elif event.is_action_pressed("zoom_out"):
		zoom -= Vector2(zoom_spd, zoom_spd)
		zoom = clamp(zoom, min_zoom, max_zoom)

func _on_main_scene_child_entered_tree(new_child: Node):
	if new_child is CharacterBody2D:
		current_vehicle = new_child
		reparent(current_vehicle, false)

func _on_main_scene_child_exiting_tree(removed_child: Node):
	if removed_child is CharacterBody2D:
		if current_vehicle != null:
			reparent($"..")
			current_vehicle = null
