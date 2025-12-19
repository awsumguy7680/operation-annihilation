class_name Jet extends CharacterBody2D

#Constants
const SPEED = 10000.0
const GRAVITY = 98000.0
const THRUST = 1600.0
const PITCH_RATE = 60.0
const JUMP_VELOCITY = -400.0
var MISSILE = Preloader.MISSILE
var BULLET = Preloader.BULLET
var MINIGUN_BULLET_SPRITE = Preloader.MINIGUN_BULLET_SPRITE
var AIM_12_SPRITES = Preloader.AIM_12_SPRITES
var AGM_90_SPRITES = Preloader.AGM_90_SPRITES

#Bodies
@onready var body: AnimatedSprite2D = $Body
@onready var cannon: Marker2D = $Body/Cannon
@onready var afterburner: AnimatedSprite2D = $Body/Afterburner
@onready var elevator: Sprite2D = $Body/Elevator
@onready var weapon_bay: Marker2D = $Body/WeaponBay
@onready var engine_sound: AudioStreamPlayer2D = $EngineSound
@onready var hitbox: CollisionPolygon2D = $Hitbox
@onready var gear_collision_box: CollisionShape2D = $Gear

#stats
@export var health: int
@export var armor: int
@export var rotary_cannon_ammo: int
@export var agms: int
@export var ir_missiles: int
@export var gear_down: bool
var despawning = false
var flying_left = true
var is_rotating = false
var gear_moving = false
var rotary_cannon_shooting = false
var on_cooldown = false
var flared = false
var incoming_missiles: int = 0
var potential_target
var target
var spd = 0.0

#UI
@onready var crosshair: Sprite2D = $"../Crosshair"
@onready var death_screen: Control = $"../CanvasLayer/DeathScreen"
@onready var death_text: Label = $"../CanvasLayer/DeathScreen/YouDied"
@onready var lock_on_timer: Timer = $Lock_Timer
@onready var time_2_lock_display: RichTextLabel = $"../Crosshair/Time2Lock"

#SFX/FX
@onready var gun_sound: AudioStreamPlayer2D = $Body/Cannon/GunSound

#Weapons
var weapons: Array = ["Rotary Cannon", "AGM-90", "AIM-12"]
var current_weapon = "Rotary Cannon"

func _ready() -> void:
	Music.set_music(Music.JET_THEME)

func _physics_process(delta: float) -> void:
	var forward := transform.x.normalized()
	
	if health > 0 and not despawning:
		#Throttle
		if Input.is_key_pressed(KEY_A):
			spd -= THRUST * delta
			afterburner.visible = true
		elif Input.is_key_pressed(KEY_D):
			spd += THRUST * 0.5 * delta
		
		if not Input.is_key_pressed(KEY_A):
			afterburner.visible = false
			if spd < 0:
				spd += THRUST * 0.2 * delta
				if spd > 0:
					spd = 0
			elif spd > 0:
				spd -= THRUST * 0.2 * delta
				if spd < 0:
					spd = 0
		
		spd = clamp(spd, -SPEED, SPEED)
		
		velocity = forward * spd
		
		if abs(spd) < 4000:
			velocity += Vector2(0, GRAVITY * delta)
		else:
			#Pitch
			if Input.is_key_pressed(KEY_W):
				rotation_degrees += PITCH_RATE * delta
			elif Input.is_key_pressed(KEY_S):
				rotation_degrees -= PITCH_RATE * delta
			elif not Input.is_key_pressed(KEY_S) or not Input.is_key_pressed(KEY_W):
				pass
			
			if not gear_down and is_on_floor():
				health = 0

	move_and_slide()

func _process(_delta: float):
	var shooting := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var area = crosshair.target_area
	
	if health > 0 and not despawning:
		#minigun rapid fire handler, see func _input for rest of minigun code
		if shooting and rotary_cannon_shooting and rotary_cannon_ammo > 0 and current_weapon == "Rotary Cannon" and not is_rotating and not gear_down:
			var bullet20mm = BULLET.instantiate()
			self.get_parent().add_child(bullet20mm)
			bullet20mm.custom_bullet((abs(spd) + 15000), 30, true, true, MINIGUN_BULLET_SPRITE, Vector2(120, 10), Vector2(0, 5), 5, 100, 0.5)
			bullet20mm.find_child("Sprite2D").scale.x = 2.0
			bullet20mm.transform = cannon.global_transform
			rotary_cannon_ammo -= 1
			if rotary_cannon_ammo <= 0:
				gun_sound.stop()
				rotary_cannon_shooting = false
		else:
			gun_sound.stop()
			rotary_cannon_shooting = false
		
		#Target locking
		if area != null:
			if crosshair.over_area == true and (current_weapon == "AIM-12" and area.is_in_group("Air_Enemies")) or (current_weapon == "AGM-90" and area.is_in_group("Ground_Enemies")):
				if crosshair.target_area.get_parent().name == "MainScene":
					potential_target = crosshair.target_area
				else:
					potential_target = crosshair.target_area.get_parent()
				crosshair.global_position = crosshair.global_position.lerp(potential_target.global_position, 0.8)
				if lock_on_timer.is_stopped() and target == null:
					lock_on_timer.start()
					time_2_lock_display.visible = true
			elif not crosshair.over_area or not (current_weapon == "AIM-12" and area.is_in_group("Air_Enemies")) or not (current_weapon == "AGM-90" and area.is_in_group("Ground_Enemies")):
				target = null
				potential_target = null
				time_2_lock_display.visible = false
				if not lock_on_timer.is_stopped():
					lock_on_timer.stop()
		else:
			target = null
			potential_target = null
			time_2_lock_display.visible = false
			if not lock_on_timer.is_stopped():
				lock_on_timer.stop()
				
		if not lock_on_timer.is_stopped():
			time_2_lock_display.text = "LOCKING..." + str("%.2f" % lock_on_timer.time_left)
	
	elif health <= 0 and not despawning:
		despawning = true
		death_screen.visible = true
		var random_text_num = randi_range(0, 3)
		if random_text_num == 0:
			death_text.text = "EJECTED"
		elif random_text_num == 1:
			death_text.text = "REST IN PIECES"
		elif random_text_num == 2:
			death_text.text = "SHOT DOWN"
		elif random_text_num == 3:
			death_text.text = "DESTROYED"
		await get_tree().create_timer(3, false).timeout
		despawning = false
		death_screen.visible = false
		get_tree().change_scene_to_file("res://assets/selection_menu.tscn")
		queue_free()

func _input(event: InputEvent):
	if health > 0 and not despawning:
		if event is InputEventKey:
			if event.keycode == KEY_G and not gear_moving and not is_on_floor() and not is_rotating:
				if flying_left:
					body.animation = "gear"
				else:
					body.animation = "gear_mirrored"
					print(body.animation)
				gear_moving = true
				if gear_down:
					gear_down = false
					body.play_backwards()
					gear_collision_box.disabled = true
					await body.animation_finished
					gear_moving = false
					return
				if not gear_down:
					gear_down = true
					body.play()
					gear_collision_box.disabled = false
					await body.animation_finished
					gear_moving = false
					return
			elif event.keycode == KEY_1:
				current_weapon = weapons[0]
				if rotary_cannon_shooting:
					rotary_cannon_shooting = false
					gun_sound.stop()
				crosshair.texture = Preloader.CROSS_GUN
			elif event.keycode == KEY_2:
				current_weapon = weapons[1]
				crosshair.texture = Preloader.CROSS_OPTICAL
				time_2_lock_display.add_theme_color_override("default_color", Color(255.0, 0.0, 0.0)) 
			elif event.keycode == KEY_3:
				current_weapon = weapons[2]
				crosshair.texture = Preloader.CROSS_IR
				time_2_lock_display.add_theme_color_override("default_color", Color(0.0, 255.0, 0.0)) 
		elif event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and not is_rotating and not gear_down:
				if current_weapon == "Rotary Cannon" and rotary_cannon_ammo > 0 and not rotary_cannon_shooting:
					rotary_cannon_shooting = true
					gun_sound.play()
				elif current_weapon == "AGM-90" and agms > 0 and not on_cooldown:
					if target != null and target.is_in_group("Ground_Enemies"):
						on_cooldown = true
						agms -= 1
						open_bay_door()
						var agm: Missile = MISSILE.instantiate()
						self.get_parent().add_child(agm)
						agm.custom_missile_static_properties(AGM_90_SPRITES, Vector2(0.0, 5.0), Vector2(190.0, 50.0), Vector2(-5.0, 0.0), 10, Preloader.ROCKETMOTORLOOP)
						agm.custom_missile_handler(true, 100, "OPTICAL", target, -(abs(spd) + 11000), 1000, 4, 0.8, true)
						agm.global_transform = weapon_bay.global_transform
						if not flying_left:
							agm.rotation_degrees += 180
						await get_tree().create_timer(2.0, false).timeout
						on_cooldown = false
				elif current_weapon == "AIM-12" and ir_missiles > 0 and not on_cooldown:
					if target != null and target.is_in_group("Air_Enemies"):
						on_cooldown = true
						ir_missiles -= 1
						open_bay_door()
						var msl = MISSILE.instantiate()
						self.get_parent().add_child(msl)
						msl.custom_missile_static_properties(AIM_12_SPRITES, Vector2(0.0, 0.0), Vector2(160.0, 60.0), Vector2(0.0, 0.0), 10, Preloader.ROCKETMOTORLOOP)
						msl.custom_missile_handler(true, 25, "IR", target, -(abs(spd) + 11000), 120, 2, 1.1, true)
						msl.global_transform = weapon_bay.global_transform
						if not flying_left:
							msl.rotation_degrees += 180
						await get_tree().create_timer(2.0, false).timeout
						on_cooldown = false

func open_bay_door():
	if flying_left:
		body.animation = "bay_door"
	else:
		body.animation = "bay_door_mirrored"
	body.play()
	await body.animation_finished
	body.play_backwards()

func damage(damage_amount: int):
	health -= damage_amount

func msl_alert(incoming: bool, _missile, _missile_guidance):
	if incoming:
		incoming_missiles += 1
	else:
		incoming_missiles -= 1

func _on_lock_timer_timeout() -> void:
	if potential_target:
		target = potential_target
		potential_target = null
		time_2_lock_display.text = "LOCKED"
