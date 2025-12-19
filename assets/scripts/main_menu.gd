extends Control

func _ready() -> void:
	Music.set_music(Music.MENU_THEME)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/selection_menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
