extends State
class_name Driving_left

@onready var tank: CharacterBody2D = $"../.."
@onready var chassis: AnimatedSprite2D = $"../../Chassis"
@onready var wreck: Sprite2D = $"../../Wreck"
@onready var chassis_hitbox: CollisionPolygon2D = $"../../ChassisHitbox"
@onready var chassis_rotate_timer: Timer = $"../../Chassis_Rotate_Timer"

func set_chassis():
	tank.is_rotating = false
	chassis.animation = "default"
	chassis.position = Vector2(-420.0, 0.0)
	chassis_hitbox.scale.x = 1.0
	chassis_hitbox.position.x = -35.0
	wreck.flip_h = false
	wreck.position.x = -120.0

func enter_state():
	set_chassis()

func Physics_Update(_delta: float):
	if Input.is_key_pressed(KEY_A) and tank.is_rotating == false:
		chassis.play("default")
	elif Input.is_key_pressed(KEY_D) and tank.is_rotating == false:
		chassis.play_backwards("default")
		
	if tank.velocity.x > 500:
		if chassis_rotate_timer.is_stopped():
			chassis_rotate_timer.start()
	else:
		if not chassis_rotate_timer.is_stopped():
			chassis_rotate_timer.stop()
			
func _on_chassis_rotate_timer_timeout() -> void:
	transitioned_state.emit(self, "Rotate_chassis_right")
