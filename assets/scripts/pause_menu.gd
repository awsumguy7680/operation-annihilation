extends Control

func _input(event: InputEvent):
	if event.is_action_pressed("pause") and not get_tree().paused:
		visible = true
		get_tree().paused = true
	elif event.is_action_pressed("pause") and get_tree().paused:
		visible = false
		get_tree().paused = false

func _on_resume_pressed() -> void:
	if get_tree().paused:
		visible = false
		get_tree().paused = false

func _on_quit_2_selection_pressed() -> void:
	for i in get_tree().current_scene.get_children():
		if i is CharacterBody2D:
			i.queue_free()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://assets/selection_menu.tscn")

func _on_quit_game_pressed() -> void:
	get_tree().quit()
