class_name Weapon extends Node2D



@export var weapon_type: String #Automatic Gun, Semi Gun, Laser Rocket, IR MSL, O MSL, Bomb, Nuke
@onready var body: Sprite2D = $Body
@onready var launch_point: Marker2D = $LaunchPoint

func create_custom_weapon(type: String, sprite: Texture2D, launchpos: Vector2):
	weapon_type = type
	body.texture = sprite
	launch_point.position = launchpos

func shoot():
	if weapon_type == "Semi Gun":
		pass
