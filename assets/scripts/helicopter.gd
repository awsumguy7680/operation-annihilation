class_name Helicopter extends CharacterBody2D

@onready var tail_rotor: Sprite2D = $Body/TailRotor

#Constants
const SPEED = 1200.0
const JUMP_VELOCITY = -400.0

#vars
@export var health: int
@export var nose_minigun_ammo: int
@export var engine_on: bool

func _physics_process(_delta: float):
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _process(_delta: float):
	tail_rotor.rotation_degrees -= 20
