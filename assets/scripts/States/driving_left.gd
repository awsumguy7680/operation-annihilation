extends State
class_name Driving_left

@onready var tank: CharacterBody2D = $"../.."
@onready var chassis: AnimatedSprite2D = $"../../Chassis"
@onready var chassis_hitbox: CollisionPolygon2D = $"../../ChassisHitbox"
var call = false

func set_chassis():
	tank.is_rotating = false
	chassis.animation = "default"
	chassis.position = Vector2(-420.0, 0.0)
	chassis_hitbox.scale.x = 1.0
	chassis_hitbox.position.x = -35.0

func enter_state():
	set_chassis()

func start_rotate():
	await get_tree().create_timer(3).timeout
	if tank.velocity.x > 500:
		transitioned_state.emit(self, "Rotate_chassis_right")
		call = false
		return
	else:
		call = false
		return

func Physics_Update(_delta: float):
	if Input.is_key_pressed(KEY_A) and tank.is_rotating == false:
		chassis.play("default")
	elif Input.is_key_pressed(KEY_D) and tank.is_rotating == false:
		chassis.play_backwards("default")
		if call == false:
			start_rotate()
			call = true
		
	if tank.velocity.x > 500:
		if call == false:
			start_rotate()
			call = true
