class_name Helicopter extends CharacterBody2D

#Bodies
@onready var tail_rotor: Sprite2D = $Body/TailRotor
var incoming_missiles_by_type: Array = ["IR x", "RADAR x"]

#Constants
const SPEED = 3000.0
const MAX_PITCH = 10.0

#stats
@export var health: int
@export var armor: int
@export var nose_minigun_ammo: int
@export var engine_on: bool
var incoming_missiles: int = 0

#weapons
@onready var nose_minigun: Sprite2D = $Body/NoseMinigun
var weapons: Array = ["Nose Minigun", "Empty", "Empty"]
var current_weapon = weapons[0]

func _physics_process(_delta: float):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	#Horizontal Movement
	if Input.is_key_pressed(KEY_A):
		velocity.x = move_toward(velocity.x, -SPEED, SPEED / 50)
		rotation_degrees = move_toward(rotation_degrees, -MAX_PITCH, 1)
	elif Input.is_key_pressed(KEY_D):
		velocity.x = move_toward(velocity.x, SPEED, SPEED / 50)
		rotation_degrees = move_toward(rotation_degrees, MAX_PITCH, 1)
	else:
		if velocity.x < 0:
			rotation_degrees = move_toward(rotation_degrees, MAX_PITCH, 1)
		elif velocity.x > 0:
			rotation_degrees = move_toward(rotation_degrees, -MAX_PITCH, 1)
		else:
			rotation_degrees = move_toward(rotation_degrees, 0.0, 1)
		velocity.x = move_toward(velocity.x, 0, SPEED / 50)

	#Vertical Movement
	if Input.is_key_pressed(KEY_W):
		velocity.y = move_toward(velocity.y, -SPEED, SPEED / 75)
	elif Input.is_key_pressed(KEY_S):
		velocity.y = move_toward(velocity.y, SPEED, SPEED / 75)
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	move_and_slide()

func _process(_delta: float):
	tail_rotor.rotation_degrees -= 20
	
	var mouse_pos = get_global_mouse_position()
	nose_minigun.look_at(mouse_pos)
	
	if nose_minigun.rotation_degrees >= 190.0:
		nose_minigun.rotation_degrees = 190.0
	elif nose_minigun.rotation_degrees <= 125.0:
		nose_minigun.rotation_degrees = 125.0

#func _input(event: InputEvent):
	#pass

func damage(damage_amount: int):
	health -= damage_amount

func msl_alert(incoming: bool, _missile):
	if incoming:
		incoming_missiles += 1
	else:
		incoming_missiles -= 1
