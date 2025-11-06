extends Sprite2D

@onready var crosshair: Sprite2D = $"."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_float) -> void:
	var mouse_position = get_global_mouse_position()
	position = mouse_position
