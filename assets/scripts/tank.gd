class_name Player_Tank extends CharacterBody2D

#Constants
const SPEED = 600.0
var BULLET = Preloader.BULLET
var MISSILE = Preloader.MISSILE
const SHELL125_SPRITE = preload("res://assets/sprites/UMBTShell.png")
const MINIGUN_BULLET_SPRITE = preload("res://assets/sprites/MinigunRound.png")
const GTGM_MISSILE_SPRITES = preload("res://assets/sprites/UMBT_GTGM_Sprite_Frames.tres")
const ROCKETMOTORLOOP = preload("res://assets/sounds/rocketmotorloop.mp3")

#bodies
@onready var chassis: AnimatedSprite2D = $Chassis
@onready var turret_sprites: AnimatedSprite2D = $Turret
@onready var chassis_hitbox: CollisionPolygon2D = $ChassisHitbox
@onready var laser_beam: Line2D = $Turret/LaserTurret/LaserBeam
@onready var wreck: Sprite2D = $Wreck
@onready var misc_sprite: Sprite2D = $MiscSprite
var missiles_list: Dictionary = {}
var incoming_missiles_by_type: Dictionary = {"OPTICAL": 0, "BOMB": 0}
var potential_target
var target

#weapons
@onready var minigun: Sprite2D = $Turret/Minigun
@onready var cannon: Sprite2D = $Turret/Cannon
@onready var _125_mm_muzzle: Marker2D = $"Turret/Cannon/125mmMuzzle"
@onready var gtgm_launch_bay: Marker2D = $Turret/GTGMLaunchBay
@onready var minigun_muzzle: Marker2D = $Turret/Minigun/MinigunMuzzle
@onready var laser_turret: Marker2D = $Turret/LaserTurret

#sounds & effects
@onready var engine_idle_sound: AudioStreamPlayer2D = $EngineIdleSound
@onready var engine_driving_sound: AudioStreamPlayer2D = $EngineDrivingSound
@onready var gun_sound: AudioStreamPlayer2D = $Turret/Cannon/GunSound
@onready var minigun_fire_sound: AudioStreamPlayer2D = $Turret/Minigun/MinigunFireSound
@onready var minigun_spool_up_sound: AudioStreamPlayer2D = $Turret/Minigun/MinigunSpoolUp
@onready var minigun_spool_down_sound: AudioStreamPlayer2D = $Turret/Minigun/MinigunSpoolDown
@onready var cannon_muzzle_flash: AnimatedSprite2D = $Turret/Cannon/CannonMuzzleFlash
@onready var minigun_muzzle_flash: AnimatedSprite2D = $Turret/Minigun/MinigunMuzzleFlash
@onready var gtgm_launch_sound: AudioStreamPlayer2D = $Turret/GTGMLaunchBay/LaunchSound
@onready var laser_hum: AudioStreamPlayer2D = $Turret/LaserTurret/LaserHum

#UI
@onready var crosshair: Crosshair = $"../Crosshair"
@onready var target_finder: CollisionShape2D = $"../Crosshair/Area2D/TargetFinder"
@onready var lock_on_timer: Timer = $LockOn_Timer
@onready var time_2_lock_display: RichTextLabel = $"../Crosshair/Time2Lock"
@onready var death_screen: Control = $"../CanvasLayer/DeathScreen"
@onready var death_text: Label = $"../CanvasLayer/DeathScreen/YouDied"

#vehicle stats
@export var health: int
@export var armor: int
@export var cannon_ammo: int
@export var minigun_ammo: int
@export var GTGM_ammo: int
@export var laser_charge: float
@export var laser_damage: float
var despawning = false
var global_delta: float
var is_driving = false
var is_rotating = false
var is_turret_rotating = false
var facing_left = true
var turret_facing_left = true
var minigun_shooting = false
var on_cooldown = false
var incoming_missiles = 0
var weapons: Array = ["Cannon", "GTGM", "Minigun"]
var current_weapon = weapons[0]

func _physics_process(delta: float) -> void:
	if health <= 0 and not despawning:
		#Death handler
		despawning = true
		wreck.visible = true
		chassis.visible = false
		chassis.stop()
		turret_sprites.visible = false
		minigun.visible = false
		cannon.visible = false
		laser_beam.visible = false
		misc_sprite.visible = false
		for i in get_children():
			if i is Timer:
				if i.time_left > 0:
					i.stop()
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
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		if Input.is_key_pressed(KEY_A) and is_rotating == false and health > 0:
			velocity.x = move_toward(velocity.x, -SPEED, SPEED / 50)
		elif Input.is_key_pressed(KEY_D) and is_rotating == false and health > 0:
			velocity.x = move_toward(velocity.x, SPEED, SPEED / 50)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED / 25)
			if is_rotating == false:
				chassis.pause()
		
		#Point the cannon & minigun at the cursor, within a certain angle limit
		var mouse_pos = get_global_mouse_position()
		
		cannon.look_at(mouse_pos)
		minigun.look_at(mouse_pos)
		
		if turret_facing_left == true:
			if cannon.rotation_degrees >= 196:
				cannon.rotation_degrees = 196
			elif cannon.rotation_degrees <= 165:
				cannon.rotation_degrees = 165
			
			if minigun.rotation_degrees >= 270:
				minigun.rotation_degrees = 270
			elif minigun.rotation_degrees <= 167:
				minigun.rotation_degrees = 167
		else:
			if cannon.rotation_degrees <= -16:
				cannon.rotation_degrees = -16
			elif cannon.rotation_degrees >= 15:
				cannon.rotation_degrees = 15
			
			if minigun.rotation_degrees <= -90:
				minigun.rotation_degrees = -90
			elif minigun.rotation_degrees >= 13:
				minigun.rotation_degrees = 13
		
		#Laser Turret Handler
		var closest_missiles: Array = []
		var closest_msl = null
		var closest_msl_global_pos: Vector2 = Vector2.ZERO
		var laser_firing = false
		
		#This basically finds the distance of all of the current missiles in the air to the tank and then it finds the minimum value in that list and that value is set to closest_msl
		for key in missiles_list.keys():
			var m = missiles_list[key]
			if not is_instance_valid(m):
				missiles_list.erase(key)
			elif m is Area2D and is_instance_valid(m):
				closest_missiles.append(m.global_position.distance_to(global_position))
		
		if missiles_list.size() > 0:
			if closest_missiles.size() > 0:
				var closest_msl_dist = closest_missiles.min()
				
				closest_msl = null
				for key in missiles_list:
					var m = missiles_list[key]
					if m is Area2D and m.global_position.distance_to(global_position) == closest_msl_dist:
						closest_msl = m
						closest_msl_global_pos = m.global_position
						break
				
				if is_instance_valid(closest_msl):
					var angle_to_msl = laser_turret.global_position.angle_to(closest_msl_global_pos)
					if abs(angle_to_msl) < 1.74 and closest_msl_dist < 50000 and not is_turret_rotating and laser_charge > 0.0 and health > 0:
						laser_firing = true
						laser_hum.play()
						laser_beam.visible = true
						laser_beam.points = [to_local(laser_turret.global_position + Vector2(-75, 330)), to_local(closest_msl_global_pos + Vector2(-75, 360))]
						closest_msl.missile_damage(laser_damage * delta)
						laser_charge -= 1
					else:
						closest_msl = null
						laser_firing = false
						laser_beam.visible = false
						laser_hum.stop()
				else:
					closest_msl = null
					laser_firing = false
					laser_beam.visible = false
					laser_hum.stop()
		else:
			closest_msl = null
			laser_firing = false
			laser_beam.visible = false
			laser_hum.stop()
		
		if not laser_firing:
			laser_charge = move_toward(laser_charge, 100, 0.5)
		
		move_and_slide()

func _process(_delta: float) -> void:
	var direction := Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_D)
	var shooting := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	if health > 0:
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
		if shooting and minigun_shooting == true and minigun_ammo > 0 and current_weapon == "Minigun" and not is_turret_rotating:
			minigun_muzzle_flash.play()
			var bullet762 = BULLET.instantiate()
			self.get_parent().add_child(bullet762)
			bullet762.custom_bullet(9000, 5, true, true, MINIGUN_BULLET_SPRITE, Vector2(120, 10), Vector2(0, 5), 5, 25, 1.0)
			bullet762.find_child("Sprite2D").scale.x = 2.0
			bullet762.transform = minigun_muzzle.global_transform
			minigun_ammo -= 1
			if minigun_ammo <= 0:
				minigun_fire_sound.stop()
				minigun_shooting = false
				minigun_muzzle_flash.stop()
				minigun_spool_down_sound.play()
		else:
			minigun_fire_sound.stop()
			minigun_shooting = false
			minigun_muzzle_flash.stop()
		
		#Target locking
		if crosshair.over_area == true and current_weapon == "GTGM":
			if crosshair.target_area.get_parent().name == "MainScene":
				potential_target = crosshair.target_area
			else:
				potential_target = crosshair.target_area.get_parent()
			crosshair.global_position = crosshair.global_position.lerp(potential_target.global_position, 0.8)
			if lock_on_timer.is_stopped() and target == null:
				lock_on_timer.start()
				time_2_lock_display.visible = true
		elif not crosshair.over_area or current_weapon != "GTGM":
			target = null
			potential_target = null
			time_2_lock_display.visible = false
			if not lock_on_timer.is_stopped():
				lock_on_timer.stop()
		
		if not lock_on_timer.is_stopped():
			time_2_lock_display.text = "LOCKING..." + str("%.2f" % lock_on_timer.time_left)

#Function to add cooldowns for different weapons to prevent rapid firing
func weapons_cooldown(cooldown: int) -> void:
	on_cooldown = true
	await get_tree().create_timer(cooldown, false).timeout
	on_cooldown = false

func _input(event) -> void:
	#weapons selection
	if health > 0 and not despawning:
		if event is InputEventKey and event.is_pressed():
			if event.keycode == KEY_1:
				current_weapon = weapons[0]
				if minigun_shooting or minigun_muzzle_flash.is_playing():
					minigun_shooting = false
					minigun_muzzle_flash.stop()
					minigun_fire_sound.stop()
					minigun_spool_down_sound.play()
				crosshair.texture = preload("res://assets/sprites/Crosshair.png")
			elif event.keycode == KEY_2:
				current_weapon = weapons[1]
				crosshair.texture = preload("res://assets/sprites/MissileCrosshair.png")
			elif event.keycode == KEY_3:
				current_weapon = weapons[2]
				crosshair.texture = preload("res://assets/sprites/Crosshair.png")
		#shooting
		elif event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and not is_turret_rotating:
				if current_weapon == "Cannon" and cannon_ammo > 0 and on_cooldown == false:
					gun_sound.play()
					cannon_muzzle_flash.play()
					var shell_instance = BULLET.instantiate()
					self.get_parent().add_child(shell_instance)
					shell_instance.custom_bullet(10000, 500, true, true, SHELL125_SPRITE, Vector2(120, 30), Vector2(0, 5), 5, 1000, 0.0)
					shell_instance.transform = _125_mm_muzzle.global_transform
					cannon_ammo -= 1
					weapons_cooldown(3)
				elif current_weapon == "Minigun" and minigun_ammo > 0 and minigun_shooting == false:
					#see func _process for minigun shooting code
					minigun_spool_up_sound.play()
					await get_tree().create_timer(0.5, false).timeout
					minigun_shooting = true
					minigun_fire_sound.play()
				elif current_weapon == "GTGM" and GTGM_ammo > 0 and on_cooldown == false:
					if target == null:
						time_2_lock_display.visible = true
						time_2_lock_display.text = "NO TARGET"
						await get_tree().create_timer(0.5, false).timeout
						time_2_lock_display.visible = false
					else:
						turret_sprites.play()
						on_cooldown = true
						await get_tree().create_timer(0.5, false).timeout
						GTGM_ammo -= 1
						var GTGM: Missile = MISSILE.instantiate()
						self.get_parent().add_child(GTGM)
						GTGM.custom_missile_static_properties(GTGM_MISSILE_SPRITES, Vector2(630, 65), Vector2(120, 70), Vector2(-10, 0), 15, ROCKETMOTORLOOP)
						GTGM.custom_missile_handler(true, 25, "OPTICAL", target, 10000, 120, 3, 3.5, true)
						GTGM.find_child("AnimatedSprite2D").flip_h = true
						GTGM.global_transform = gtgm_launch_bay.global_transform
						if turret_facing_left:
							GTGM.global_rotation_degrees = 180
						gtgm_launch_sound.play()
						await get_tree().create_timer(0.5, false).timeout
						turret_sprites.play_backwards()
						await get_tree().create_timer(0.5, false).timeout
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

#Function that tracks incoming missiles and triggers alerts
func msl_alert(incoming: bool, missile, missile_guidance: String):
	if incoming:
		incoming_missiles += 1
		missiles_list[missile.name] = missile
		incoming_missiles_by_type[missile_guidance] += 1
	else:
		incoming_missiles -= 1
		missiles_list.erase(missile.name)
		incoming_missiles_by_type[missile_guidance] -= 1

#Locks the target when the lock_on_timer thats fired in _process is done
func _on_lock_on_timer_timeout() -> void:
	if potential_target:
		target = potential_target
		potential_target = null
		time_2_lock_display.text = "LOCKED"
