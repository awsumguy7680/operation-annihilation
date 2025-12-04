extends State
class_name Rotate_Turret_Right

@onready var tank: CharacterBody2D = $"../.."
@onready var turret: AnimatedSprite2D = $"../../Turret"
@onready var minigun: Sprite2D = $"../../Turret/Minigun"
@onready var cannon: Sprite2D = $"../../Turret/Cannon"
@onready var gtgm_launch_bay: Marker2D = $"../../Turret/GTGMLaunchBay"
@onready var laser_turret: Marker2D = $"../../Turret/LaserTurret"
@onready var misc_sprite: Sprite2D = $"../../MiscSprite"

func enter_state():
	tank.is_turret_rotating = true
	turret.position = Vector2(120.0, -80.0)
	cannon.position = Vector2(400.0, 30.0)
	cannon.offset = Vector2(0.0, 45.0)
	minigun.position = Vector2(65.0, -155.0)
	minigun.offset = Vector2(335.0, 235.0)
	gtgm_launch_bay.position = Vector2(-240.0, 10.0)
	laser_turret.position = Vector2(-75.0, -160.0)
	minigun.visible = false
	cannon.visible = false
	minigun.flip_v = false
	cannon.flip_v = false
	turret.animation = "turret_rotation"
	turret.play()
	await turret.animation_finished
	tank.is_rotating = false
	misc_sprite.visible = true
	minigun.visible = true
	cannon.visible = true
	transitioned_state.emit(self, "Looking_Right")
