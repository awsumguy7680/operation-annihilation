extends State
class_name Rotate_chassis_left

@onready var tank: CharacterBody2D = $"../.."
@onready var chassis: AnimatedSprite2D = $"../../Chassis"
var done_rotating = false

func enter_state():
	tank.is_rotating = true
	chassis.position = Vector2(-120.0, -80.0)
	chassis.animation = "rotation"
	chassis.play_backwards()
	await chassis.animation_finished
	done_rotating = true
	tank.is_rotating = false
	transitioned_state.emit(self, "Driving_left")
