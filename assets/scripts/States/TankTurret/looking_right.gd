extends State
class_name Looking_Right

@onready var tank: CharacterBody2D = $"../.."
@onready var crosshair: Sprite2D = $"../../../Crosshair"
@onready var turret: AnimatedSprite2D = $"../../Turret"
@onready var turret_hitbox: CollisionPolygon2D = $"../../TurretHitbox"
@onready var turret_rotate_timer: Timer = $"../../Turret_Rotate_Timer"


func enter_state():
	tank.is_turret_rotating = false
	tank.turret_facing_left = false
	turret.animation = "default_mirrored"
	turret.position = Vector2(120.0, -80.0)
	turret.offset = Vector2(-240.0, 0.0)
	turret_hitbox.scale.x = -1.0
	turret_hitbox.position.x = 85.0

func Update(_delta: float):
	var cross_angle2turret = rad_to_deg(tank.get_angle_to(crosshair.global_position))
	if abs(cross_angle2turret) >= 90:
		if turret_rotate_timer.is_stopped():
			turret_rotate_timer.start()
	elif abs(cross_angle2turret) <= 90:
		if not turret_rotate_timer.is_stopped():
			turret_rotate_timer.stop()

func _on_turret_rotate_timer_timeout() -> void:
	transitioned_state.emit(self, "Rotate_Turret_Left")
