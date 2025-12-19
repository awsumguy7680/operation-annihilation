class_name Helicopter extends CharacterBody2D

#Bodies
@onready var tail_rotor: Sprite2D = $Body/TailRotor
@onready var muzzle: Marker2D = $Body/NoseMinigun/Muzzle
var incoming_missiles_by_type: Dictionary = {"IR": 0, "RADAR": 0}

#Constants
const SPEED = 3000.0
const MAX_PITCH = 10.0
var MISSILE = Preloader.MISSILE
var BULLET = Preloader.BULLET
var MINIGUN_BULLET_SPRITE = Preloader.MINIGUN_BULLET_SPRITE
var RKT_50_SPRITES = Preloader.RKT_50_SPRITES
var AIM_12_SPRITES = Preloader.AIM_12_SPRITES

#stats
@export var health: int
@export var armor: int
@export var nose_minigun_ammo: int
@export var rockets: int
@export var ir_missiles: int = 2
@export var engine_on: bool
var despawning = false
var flying_left = true
var is_rotating = false
var minigun_shooting = false
var on_cooldown = false
var mouse_held = false
var flared = false
var incoming_missiles: int = 0
var potential_target
var target

#UI
@onready var crosshair: Crosshair = $"../Crosshair"
@onready var death_screen: Control = $"../CanvasLayer/DeathScreen"
@onready var death_text: Label = $"../CanvasLayer/DeathScreen/YouDied"
@onready var lock_on_timer: Timer = $IR_Lock_Timer
@onready var time_2_lock_display: RichTextLabel = $"../Crosshair/Time2Lock"

#SFX/FX
@onready var minigun_fire_sound: AudioStreamPlayer2D = $Body/NoseMinigun/MinigunFireSound
@onready var minigun_spool_up: AudioStreamPlayer2D = $Body/NoseMinigun/MinigunSpoolUp
@onready var minigun_spool_down: AudioStreamPlayer2D = $Body/NoseMinigun/MinigunSpoolDown

#weapons
@onready var nose_minigun: AnimatedSprite2D = $Body/NoseMinigun
@onready var rocket_pod: AnimatedSprite2D = $Body/InnerPylon/RocketPod
@onready var ir_missile: AnimatedSprite2D = $Body/OuterPylon/IRMissile

#@onready var inner_pylon: Marker2D = $Body/InnerPylon
#@onready var outer_pylon: Marker2D = $Body/OuterPylon
#var weapons: Dictionary = {}
var weapons: Array = ["Nose Minigun", "RKT-50", "AIM-12"]
var current_weapon = "Nose Minigun"

func _ready() -> void:
	Music.set_music(Music.HELI_THEME)
	#weapons["Nose Minigun"] = nose_minigun_ammo
	#
	#for hardpoint_name in PlayerVehicleLoader.loadout:
		#var weapon_name = PlayerVehicleLoader.loadout[hardpoint_name]
		#if weapon_name == "Empty":
			#continue
		#if weapon_name == "GTGM":
			#var msl = MISSILE.instantiate()
			#msl.custom_missile_static_properties(Preloader.GTGM_MISSILE_SPRITES, Vector2(630, 65), Vector2(120, 70), Vector2(-10, 0), 15, Preloader.ROCKETMOTORLOOP)
			#msl.custom_missile_handler(true, 25, "OPTICAL", target, 10000, 120, 3, 3.5, false)
			#outer_pylon.add_child(msl)

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
	var shooting := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	if health <= 0 and not despawning:
		despawning = true
		death_screen.visible = true
		var random_text_num = randi_range(0, 3)
		if random_text_num == 0:
			death_text.text = "OBLITERATED"
		elif random_text_num == 1:
			death_text.text = "COMBAT INEFFECTIVE"
		elif random_text_num == 2:
			death_text.text = "SHOT DOWN"
		elif random_text_num == 3:
			death_text.text = "DESTROYED"
		await get_tree().create_timer(3, false).timeout
		despawning = false
		death_screen.visible = false
		get_tree().change_scene_to_file("res://assets/selection_menu.tscn")
		queue_free()
	else:
		if flying_left:
			tail_rotor.rotation_degrees -= 20
		else:
			tail_rotor.rotation_degrees += 20
		
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
		
		#minigun rapid fire handler, see func _input for rest of minigun code
		if shooting and minigun_shooting == true and nose_minigun_ammo > 0 and current_weapon == "Nose Minigun" and not is_rotating:
			nose_minigun.animation = "firing"
			nose_minigun.play()
			var bullet762 = BULLET.instantiate()
			self.get_parent().add_child(bullet762)
			bullet762.custom_bullet(9000, 5, true, true, MINIGUN_BULLET_SPRITE, Vector2(120, 10), Vector2(0, 5), 5, 25, 1.0)
			bullet762.find_child("Sprite2D").scale.x = 2.0
			bullet762.transform = muzzle.global_transform
			nose_minigun_ammo -= 1
			if nose_minigun_ammo <= 0:
				minigun_fire_sound.stop()
				minigun_shooting = false
				nose_minigun.animation = "default"
				nose_minigun.stop()
				minigun_spool_down.play()
		else:
			minigun_fire_sound.stop()
			minigun_shooting = false
			nose_minigun.animation = "default"
			nose_minigun.stop()
	
	#Target locking
	if crosshair.over_area == true and current_weapon == "AIM-12" and crosshair.target_area.is_in_group("Air_Enemies"):
		if crosshair.target_area.get_parent().name == "MainScene":
			potential_target = crosshair.target_area
		else:
			potential_target = crosshair.target_area.get_parent()
		crosshair.global_position = crosshair.global_position.lerp(potential_target.global_position, 0.8)
		if lock_on_timer.is_stopped() and target == null:
			lock_on_timer.start()
			time_2_lock_display.visible = true
	elif not crosshair.over_area or current_weapon != "AIM-12" or not crosshair.target_area.is_in_group("Air_Enemies"):
		target = null
		potential_target = null
		time_2_lock_display.visible = false
		if not lock_on_timer.is_stopped():
			lock_on_timer.stop()
	
	if not lock_on_timer.is_stopped():
		time_2_lock_display.text = "LOCKING..." + str("%.2f" % lock_on_timer.time_left)

func _input(event: InputEvent):
	if health > 0 and not despawning:
		if event is InputEventKey:
			if event.keycode == KEY_1:
				current_weapon = weapons[0]
				if minigun_shooting:
					minigun_shooting = false
					minigun_fire_sound.stop()
					minigun_spool_down.play()
				crosshair.texture = Preloader.CROSS_GUN
			elif event.keycode == KEY_2:
				current_weapon = weapons[1]
				crosshair.texture = Preloader.CROSS_LASER
			elif event.keycode == KEY_3:
				current_weapon = weapons[2]
				crosshair.texture = Preloader.CROSS_IR
				time_2_lock_display.add_theme_color_override("default_color", Color(0.0, 255.0, 0.0)) 
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and not is_rotating:
				mouse_held = true
				if current_weapon == "Nose Minigun" and nose_minigun_ammo > 0 and not minigun_shooting:
					minigun_spool_up.play()
					await get_tree().create_timer(0.5, false).timeout
					minigun_shooting = true
					minigun_fire_sound.play()
				if current_weapon == "RKT-50" and rockets > 0:
					shoot_rockets()
				if current_weapon == "AIM-12" and ir_missiles > 0 and on_cooldown == false:
					if target != null:
						on_cooldown = true
						ir_missile.visible = false
						ir_missiles -= 1
						var msl = MISSILE.instantiate()
						self.get_parent().add_child(msl)
						msl.custom_missile_static_properties(AIM_12_SPRITES, Vector2(0.0, 0.0), Vector2(160.0, 60.0), Vector2(0.0, 0.0), 10, Preloader.ROCKETMOTORLOOP)
						msl.custom_missile_handler(true, 25, "IR", target, -11000, 120, 2, 1.1, true)
						msl.global_transform = ir_missile.get_parent().global_transform
						if not flying_left:
							msl.rotation_degrees += 180
						await get_tree().create_timer(0.5, false).timeout
						on_cooldown = false
					
			elif event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
				mouse_held = false
				if minigun_shooting:
					minigun_fire_sound.stop()
					minigun_shooting = false
					nose_minigun.animation = "default"
					nose_minigun.stop()
					minigun_spool_down.play()

func shoot_rockets():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		for i in rockets:
			if mouse_held and current_weapon == "RKT-50" and rockets > 0:
				rockets -= 1
				var rkt: Missile = MISSILE.instantiate()
				self.get_parent().add_child(rkt)
				rkt.global_transform = rocket_pod.get_parent().global_transform
				rkt.custom_missile_static_properties(RKT_50_SPRITES, Vector2(0.0, 0.0), Vector2(230.0, 40.0), Vector2(-5.0, 0.0), 5, null)
				rkt.custom_missile_handler(true, 15, "LASER", null, -18000, 100, 2, 1.0, true)
				rkt.scale = Vector2(1.0, 1.0)
				rkt.z_index = rocket_pod.z_index - 1
				if not flying_left:
					rkt.rotation_degrees += 180
				await get_tree().create_timer(0.1, false).timeout
			else:
				break

func damage(damage_amount: int):
	health -= damage_amount

func msl_alert(incoming: bool, _missile, _missile_guidance):
	if incoming:
		incoming_missiles += 1
	else:
		incoming_missiles -= 1

func _on_ir_lock_timer_timeout() -> void:
	if potential_target:
		target = potential_target
		potential_target = null
		time_2_lock_display.text = "LOCKED"
