extends State
class_name Rotate_Turret_Left

@onready var tank: CharacterBody2D = $"../.."
@onready var turret: AnimatedSprite2D = $"../../Turret"
@onready var minigun: Sprite2D = $"../../Turret/Minigun"
@onready var cannon: Sprite2D = $"../../Turret/Cannon"
@onready var gtgm_launch_bay: Marker2D = $"../../Turret/GTGMLaunchBay"
@onready var laser_turret: Marker2D = $"../../Turret/LaserTurret"
@onready var misc_sprite: Sprite2D = $"../../MiscSprite"

func enter_state():
	tank.is_turret_rotating = true
	cannon.position = Vector2(-240.0, -45.0)
	cannon.offset = Vector2(0.0, -45.0)
	minigun.position = Vector2(95.0, -215.0)
	minigun.offset = Vector2(335.0, -215.0)
	gtgm_launch_bay.position = Vector2(405.0, -70.0)
	laser_turret.position = Vector2(425.0, -242.0)
	misc_sprite.visible = false
	minigun.visible = false
	cannon.visible = false
	minigun.flip_v = true
	cannon.flip_v = true
	turret.animation = "turret_rotation"
	turret.play_backwards()
	await turret.animation_finished
	turret.position = Vector2(-180.0, 0.0)
	tank.is_rotating = false
	minigun.visible = true
	cannon.visible = true
	transitioned_state.emit(self, "Looking_Left")
