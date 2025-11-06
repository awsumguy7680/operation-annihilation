extends Camera2D

var zoomed_in = true

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_I and event.is_pressed() and zoomed_in == true:
			zoom = Vector2(0.1, 0.1)
			zoomed_in = false
		elif event.keycode == KEY_I and event.is_pressed() and zoomed_in == false:
			zoom = Vector2(0.3, 0.3)
			zoomed_in = true
