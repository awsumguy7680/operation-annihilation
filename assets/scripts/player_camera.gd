extends Camera2D

var zoomed_in = true

#HUD elements
@onready var health_display: RichTextLabel = $Health
@onready var weapon_display: RichTextLabel = $WeaponDisplay
@onready var ammo_display: RichTextLabel = $Ammo
@onready var laser_charge_display: RichTextLabel = $LaserCharge

var current_vehicle = null

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_I and event.is_pressed() and zoomed_in == true:
			zoom = Vector2(0.1, 0.1)
			zoomed_in = false
		elif event.keycode == KEY_I and event.is_pressed() and zoomed_in == false:
			zoom = Vector2(0.3, 0.3)
			zoomed_in = true

func _process(_delta: float):
	if current_vehicle is Player_Tank:
		health_display.text = "Health: " + str(current_vehicle.health)
		laser_charge_display.text = "Laser Charge: " + str(current_vehicle.laser_charge) + "%"
		if current_vehicle._gun125mm and not current_vehicle._minigunselect and not current_vehicle._GTGM:
			weapon_display.text = "Weapon: Cannon"
			ammo_display.text = "Cannon Ammo: " + str(current_vehicle.cannon_ammo)
		elif current_vehicle._GTGM and not current_vehicle._gun125mm and not current_vehicle._minigunselect:
			weapon_display.text = "Weapon: Anti-Tank Missile"
			ammo_display.text = "AT Missiles: " + str(current_vehicle.GTGM_ammo)
		elif current_vehicle._minigunselect and not current_vehicle._gun125mm and not current_vehicle._GTGM:
			weapon_display.text = "Weapon: Minigun"
			ammo_display.text = "Minigun Ammo: " + str(current_vehicle.minigun_ammo)
	elif current_vehicle == Helicopter:
		pass

func _on_main_scene_child_entered_tree(new_child: Node):
	if new_child is CharacterBody2D:
		if new_child is Player_Tank:
			current_vehicle = new_child
			reparent(current_vehicle, false)

func _on_main_scene_child_exiting_tree(removed_child: Node) -> void:
	if removed_child is CharacterBody2D:
		if current_vehicle != null:
			#reparent(get_tree().current_scene)
			current_vehicle = null
