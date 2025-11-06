extends CharacterBody2D

const SPEED = 600.0
const JUMP_VELOCITY = -400.0
const MIN_ANGLE = -8
const MAX_ANGLE = 18

#bodies
@onready var chassis: AnimatedSprite2D = $Chassis
@onready var turret_sprites: AnimatedSprite2D = $Turret
@onready var hitbox: CollisionPolygon2D = $Hitbox
@export var shell125 = preload("res://assets/125_mm_shell.tscn")
@export var minigun_bullet = preload("res://assets/minigun_tracer.tscn")
@export var GTGM_missile = preload("res://assets/missile.tscn")

#weapons
@onready var minigun: Sprite2D = $Turret/Minigun
@onready var cannon: Sprite2D = $Turret/Cannon
@onready var _125_mm_muzzle: Marker2D = $"Turret/Cannon/125mmMuzzle"
@onready var gtgm_launch_bay: Marker2D = $Turret/GTGMLaunchBay
@onready var minigun_muzzle: Marker2D = $Turret/Minigun/MinigunMuzzle

#sounds & effects
@onready var engine_idle_sound: AudioStreamPlayer2D = $EngineIdleSound
@onready var engine_driving_sound: AudioStreamPlayer2D = $EngineDrivingSound
@onready var gun_sound: AudioStreamPlayer2D = $Turret/Cannon/GunSound
@onready var minigun_fire_sound: AudioStreamPlayer2D = $Turret/Minigun/MinigunFireSound
@onready var minigun_spool_up_sound: AudioStreamPlayer2D = $Turret/Minigun/MinigunSpoolUp
@onready var minigun_spool_down_sound: AudioStreamPlayer2D = $Turret/Minigun/MinigunSpoolDown
@onready var cannon_muzzle_flash: AnimatedSprite2D = $Turret/Cannon/CannonMuzzleFlash
@onready var minigun_muzzle_flash: AnimatedSprite2D = $Turret/Minigun/MinigunMuzzleFlash

#UI
@onready var weapon_display: RichTextLabel = $Camera2D/WeaponDisplay
@onready var health_display: RichTextLabel = $Camera2D/Health
@onready var ammo_display: RichTextLabel = $Camera2D/Ammo

#vehicle stats
var is_driving = false
var minigun_shooting = false
@export var health = 5000
var cannon_ammo = 100
var minigun_ammo = 4500
var GTGM_ammo = 15
var _gun125mm = true
var _minigunselect = false
var _GTGM = false
var on_cooldown = false

func _physics_process(delta: float) -> void:
	if health <= 0:
		queue_free()
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if Input.is_key_pressed(KEY_A):
		velocity.x = -SPEED
		chassis.play()
	elif Input.is_key_pressed(KEY_D):
		velocity.x = SPEED
		chassis.play_backwards()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		chassis.pause()
	
	#Point the cannon & minigun at the cursor, within a certain angle limit
	var mouse_pos = get_global_mouse_position()
	
	cannon.look_at(mouse_pos)
	if cannon.rotation_degrees >= 196:
		cannon.rotation_degrees = 196
	elif cannon.rotation_degrees <= 165:
		cannon.rotation_degrees = 165
	
	minigun.look_at(mouse_pos)
	if minigun.rotation_degrees >= 270:
		minigun.rotation_degrees = 270
	elif minigun.rotation_degrees <= 167:
		minigun.rotation_degrees = 167
	
	move_and_slide()

func _process(_delta: float) -> void:
	var direction := Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_D)
	var shooting := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	#switch between idle and driving sounds
	if direction and not is_driving:
		is_driving = true
		engine_idle_sound.stop()
		engine_driving_sound.play()
	elif not direction and is_driving:
		is_driving = false
		engine_driving_sound.stop()
		engine_idle_sound.play()
	
	#minigun rapid fire handler, see func _input for rest of minigun code
	if shooting and minigun_shooting == true and minigun_ammo > 0:
		minigun_muzzle_flash.play()
		var bullet762 = minigun_bullet.instantiate()
		owner.add_child(bullet762)
		bullet762.transform = minigun_muzzle.global_transform
		minigun_ammo -= 1
		ammo_display.text = "Minigun Ammo: " + str(minigun_ammo)
		if minigun_ammo <= 0:
			minigun_fire_sound.stop()
			minigun_shooting = false
			minigun_muzzle_flash.stop()
			minigun_spool_down_sound.play()
	else:
		minigun_fire_sound.stop()
		minigun_shooting = false
		minigun_muzzle_flash.stop()

#Function to add cooldowns for different weapons to prevent rapid firing
func weapons_cooldown(cooldown: int) -> void:
	on_cooldown = true
	await get_tree().create_timer(cooldown).timeout
	on_cooldown = false

#function to quickly run through weapon selection
func _weapons_handler(gun_select, minigun_select, AT_select):
	_gun125mm = gun_select
	_minigunselect = minigun_select
	_GTGM = AT_select

func _input(event) -> void:
	#weapons selection
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_1:
			_weapons_handler(true, false, false)
			if minigun_shooting or minigun_muzzle_flash.is_playing():
				minigun_shooting = false
				minigun_muzzle_flash.stop()
				minigun_fire_sound.stop()
				minigun_spool_down_sound.play()
			weapon_display.text = "Weapon: Cannon"
			ammo_display.text = "Cannon Ammo: " + str(cannon_ammo)
		elif event.keycode == KEY_2:
			_weapons_handler(false, false, true)
			weapon_display.text = "Weapon: Anti-Tank Missile"
			ammo_display.text = "AT Missiles: " + str(GTGM_ammo)
		elif event.keycode == KEY_3:
			_weapons_handler(false, true, false)
			weapon_display.text = "Weapon: Minigun"
			ammo_display.text = "Minigun Ammo: " + str(minigun_ammo)
	#shooting
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			if _gun125mm == true and _minigunselect == false and _GTGM == false and cannon_ammo > 0 and on_cooldown == false:
				gun_sound.play()
				cannon_muzzle_flash.play()
				var shell_instance = shell125.instantiate()
				owner.add_child(shell_instance)
				shell_instance.transform = _125_mm_muzzle.global_transform
				cannon_ammo -= 1
				ammo_display.text = "Cannon Ammo: " + str(cannon_ammo)
				weapons_cooldown(3)
			elif _minigunselect == true and _gun125mm == false and _GTGM == false and minigun_ammo > 0 and minigun_shooting == false:
				#see func _process for minigun shooting code
				minigun_spool_up_sound.play()
				await get_tree().create_timer(0.5).timeout
				minigun_shooting = true
				minigun_fire_sound.play()
			elif _GTGM == true and _gun125mm == false and _minigunselect == false and GTGM_ammo > 0 and on_cooldown == false:
				turret_sprites.play()
				on_cooldown = true
				GTGM_ammo -= 1
				#var GTGM = GTGM_missile.instantiate()
				#owner.add_child(GTGM)
				#GTGM.transform = gtgm_launch_bay.global_transform
				ammo_display.text = "AT Missiles: " + str(GTGM_ammo)
				await get_tree().create_timer(1.5).timeout
				turret_sprites.play_backwards()
				on_cooldown = false
		elif event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			if minigun_muzzle_flash.is_playing():
				minigun_fire_sound.stop()
				minigun_shooting = false
				minigun_muzzle_flash.stop()
				minigun_spool_down_sound.play()

#Function to take damage when hit by munitions
func damage(damage_amount: int) -> void:
	health -= damage_amount
	health_display.text = "Health: " + str(health)
