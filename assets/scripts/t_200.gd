extends Area2D

#Constants
const SPEED = 200
const STOP_DISTANCE: float = 6000
const CANNON_SHOOT_DISTANCE: float = 12000.0
const MSL_SHOOT_DISTANCE: float = 15000.0
const MG_SHOOT_DISTANCE: float = 8000.0
var BULLET = Preloader.BULLET
var MISSILE = Preloader.MISSILE
var SHEL125_SPRITE = Preloader.SHELL125_SPRITE
#const MG_BULLET_SPRITE = 

#Variables for nodes
@onready var turret: AnimatedSprite2D = $Turret
@onready var main_gun: AnimatedSprite2D = $Turret/MainGun
@onready var cannon_muzzle: Marker2D = $Turret/MainGun/CannonMuzzle
@onready var cannon_muzzle_flash: AnimatedSprite2D = $Turret/MainGun/CannonMuzzleFlash
@onready var mg: AnimatedSprite2D = $Turret/MG
@onready var chassis: AnimatedSprite2D = $Chassis
@onready var hitbox: CollisionPolygon2D = $Hitbox
@onready var wreck: Sprite2D = $Wreck
@onready var launch_tube: Marker2D = $Turret/LaunchTube
@onready var main_scene = get_tree().current_scene
var player_target = null

#Self Variables
var is_shooting = false
var past_max_turret_angle = false
var past_max_mg_angle = false
var on_cooldown = false
@export var health: int
@export var armor: int
@export var cannon_ammo: int
@export var msl_ammo: int
@export var mg_ammo: int
@export var value: int
@export var facing_left: bool
var ammo

func _ready():
	if facing_left:
		pass

func _process(delta: float):
	position.y = -270.0
	ammo = cannon_ammo + msl_ammo + mg_ammo
	
	if health > 0:
		if player_target:
			var distance = global_position.distance_to(player_target.global_position)
			
			mg.look_at(player_target.global_position)
			main_gun.look_at(player_target.global_position)
			
			# Checks distance between the vehicle and the player, stops within a certain distance.
			if distance >= STOP_DISTANCE:
				if facing_left:
					position.x -= SPEED * delta
				else:
					position.x += SPEED * delta
				chassis.play()
			else:
				position.x = position.x
				chassis.pause()
			
			#Starts shooting within a certain distance
			#Cannon
			if distance <= CANNON_SHOOT_DISTANCE and not on_cooldown and cannon_ammo > 0 and not past_max_turret_angle:
				on_cooldown = true
				cannon_muzzle_flash.play()
				var shell =  BULLET.instantiate()
				self.get_parent().add_child(shell)
				shell.custom_bullet(10000, 400, false, true, SHEL125_SPRITE, Vector2(120, 30), Vector2(0, 5), 5, 900, 0.0)
				shell.global_transform = cannon_muzzle.global_transform
				cannon_ammo -= 1
				await get_tree().create_timer(2.5, false).timeout
				on_cooldown = false
			#MG
			#if distance <= MG_SHOOT_DISTANCE and is_shooting == false and mg_ammo > 0 and not past_max_mg_angle:
				#is_shooting = true
				#mg.play()
				#mg_shooting()
			#elif distance >= GUN_SHOOT_DISTANCE or gun_ammo <= 0 or past_max_gun_angle:
				#is_shooting = false
				#mg.stop()
			
			#Missiles
			#if distance <= MSL_SHOOT_DISTANCE and on_cooldown == false and msl_ammo > 0 and player_target is Player_Tank:
				#msl_ammo -= 1
				#on_cooldown = true
				#var missile_instance: Missile = MISSILE.instantiate()
				#owner.add_child(missile_instance)
				#missile_instance.transform = launch_tube.global_transform
				#missile_instance.scale = Vector2(1.0, 1.0,)
				#if missile_instance:
					#missile_instance.custom_missile_static_properties(RFV_MSL_SPRITE_FRAMES, Vector2(0.0, 0.0), Vector2(110.0, 40.0), Vector2(-5.0, 0.0), 10, ROCKET_MOTOR_LOOP)
					#missile_instance.custom_missile_handler(false, 25, "OPTICAL", player_target, 9000, 100, 2, 1.8, true)
				#await get_tree().create_timer(2, false).timeout
				#on_cooldown = false
		#else:
			#for child in main_scene.get_children():
				#if child is CharacterBody2D:
					#player_target = child
					#break
	else:
		#sfx.stop()
		chassis.visible = false
		turret.visible = false
		mg.visible = false
		hitbox.disabled = true
		wreck.visible = true
		await get_tree().create_timer(4, false).timeout
		GameMaster.add_score(value)
		queue_free()
		return

func enemy_damage(damage: int):
	health -= damage
