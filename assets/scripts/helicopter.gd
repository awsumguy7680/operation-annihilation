class_name Helicopter extends CharacterBody2D

#Bodies
@onready var tail_rotor: Sprite2D = $Body/TailRotor
var incoming_missiles_by_type: Dictionary = {"IR": 0, "RADAR": 0}

#Constants
const SPEED = 3000.0
const MAX_PITCH = 10.0

#stats
@export var health: int
@export var armor: int
@export var nose_minigun_ammo: int
@export var engine_on: bool
var despawning = false
var flying_left = true
var is_rotating = false
var incoming_missiles: int = 0

#UI
@onready var death_screen: Control = $"../CanvasLayer/DeathScreen"
@onready var death_text: Label = $"../CanvasLayer/DeathScreen/YouDied"

#weapons
@onready var nose_minigun: Sprite2D = $Body/NoseMinigun
var weapons: Array = ["Nose Minigun", "Empty", "Empty"]
var current_weapon = weapons[0]

func _physics_process(_delta: float):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if health > 0 and not despawning:
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
	if health <= 0 and not despawning:
		despawning = true
		death_screen.visible = true
		var random_text_num = randi_range(0, 3)
		if random_text_num == 0:
			death_text.text = "OBLITERATED"
		elif random_text_num == 1:
			death_text.text = "COMBAT INEFFECTIVE"
		elif random_text_num == 2:
			death_text.text = "KNOCKED OUT"
		elif random_text_num == 3:
			death_text.text = "DESTROYED"
		await get_tree().create_timer(3, false).timeout
		despawning = false
		death_screen.visible = false
		get_tree().change_scene_to_file("res://assets/selection_menu.tscn")
		queue_free()
	else:
		tail_rotor.rotation_degrees -= 20
		
		
		var mouse_pos = get_global_mouse_position()
		nose_minigun.look_at(mouse_pos)
		
		if flying_left:
			if nose_minigun.rotation_degrees >= 190.0:
				nose_minigun.rotation_degrees = 190.0
			elif nose_minigun.rotation_degrees <= 125.0:
				nose_minigun.rotation_degrees = 125.0
		else:
			if nose_minigun.rotation_degrees >= 415.0:
				nose_minigun.rotation_degrees = 415.0
			elif nose_minigun.rotation_degrees <= 350.0:
				nose_minigun.rotation_degrees = 350.0

func _input(event: InputEvent):
	pass

func spawn_with_loadout(hardpoint1weapon, hardpoint2weapon):
	pass

func damage(damage_amount: int):
	health -= damage_amount

func msl_alert(incoming: bool, missile, missile_guidance):
	if incoming:
		incoming_missiles += 1
	else:
		incoming_missiles -= 1
