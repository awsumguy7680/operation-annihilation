class_name Crosshair extends Sprite2D

@onready var crosshair: Sprite2D = $"."
var over_area: bool = false
var target_area = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var mouse_position = get_global_mouse_position()
	position = mouse_position

func _on_area_2d_area_entered(area: Area2D):
	if area.is_in_group("Enemies"):
		over_area = true
		target_area = area

func _on_area_2d_area_exited(area: Area2D):
	if area.is_in_group("Enemies"):
		over_area = false
		target_area = null
