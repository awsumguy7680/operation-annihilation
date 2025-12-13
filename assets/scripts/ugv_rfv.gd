extends Area2D

#Constants
const SPEED = 250
const STOP_DISTANCE: float = 5000
const GUN_SHOOT_DISTANCE: float = 8000.0
const MSL_SHOOT_DISTANCE: float = 12000.0
const BULLET = preload("res://assets/bullet.tscn")
const BULLET_SPRITE = preload("res://assets/sprites/MGTracerRed.png")

#Self Variables
var is_shooting = false
var past_max_gun_angle = false
var on_cooldown = false
@export var health: int
@export var armor: int
@export var gun_ammo: int
@export var msl_ammo: int
@export var facing_left: bool

#Variables for nodes
var player_target = null
@onready var chassis: AnimatedSprite2D = $Chassis
@onready var turret: Sprite2D = $Turret
@onready var muzzle: Marker2D = $Turret/Chaingun/Muzzle
@onready var chaingun: AnimatedSprite2D = $Turret/Chaingun
@onready var hitbox: CollisionPolygon2D = $Hitbox
@onready var wreck: Sprite2D = $Wreck
@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var main_scene = get_tree().current_scene

func _ready():
	if facing_left:
		chassis.flip_h = true
		chassis.offset.x = -100.0
		turret.flip_h = true
		turret.offset.x = -100.0
		chaingun.flip_h = true
		chaingun.offset.x = -22.0
		chaingun.position.x = -190.0
		hitbox.scale.x = -1.0
		hitbox.position.x = -80.0
		wreck.flip_h = true
		wreck.offset.x = -90.0

func _process(delta: float):
	position.y = -280.0
	
	if health > 0:
		if player_target:
			var distance = global_position.distance_to(player_target.global_position)
		
			#Makes MG turret always point at the player
			if player_target:
				chaingun.look_at(player_target.position)
				
				if facing_left:
					chaingun.rotation_degrees = clamp(chaingun.rotation_degrees, 15.0, -20.0)
				else:
					chaingun.rotation_degrees = clamp(chaingun.rotation_degrees, -20.0, 15.0)
				
				if abs(chaingun.rotation_degrees) >= 15.0 or abs(chaingun.rotation_degrees) >= 20.0:
					past_max_gun_angle = true
				else:
					past_max_gun_angle = false
			
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
			#Chaingun
			if distance <= GUN_SHOOT_DISTANCE and is_shooting == false and gun_ammo > 0 and not past_max_gun_angle:
				is_shooting = true
				chaingun.play()
				chaingun_shooting()
			elif distance >= GUN_SHOOT_DISTANCE or gun_ammo <= 0 or past_max_gun_angle:
				is_shooting = false
				chaingun.stop()
			
			#Missiles
			if distance <= MSL_SHOOT_DISTANCE and on_cooldown == false and msl_ammo > 0:
				pass
			else:
				pass
		else:
			for child in main_scene.get_children():
				if child is CharacterBody2D:
					player_target = child
					break
	else:
		#sfx.stop()
		#muzzle_flash_sprite.stop()
		chassis.visible = false
		turret.visible = false
		chaingun.visible = false
		hitbox.disabled = true
		wreck.visible = true
		await get_tree().create_timer(4, false).timeout
		queue_free()
		return
		
func chaingun_shooting():
	for i in gun_ammo:
		await get_tree().create_timer(0.1, false).timeout
		var bullet27mm: Bullet = BULLET.instantiate()
		owner.add_child(bullet27mm)
		if bullet27mm:
			bullet27mm.custom_bullet(9000, 15, false, true, BULLET_SPRITE, Vector2(20.0, 1.0), Vector2(0.0, 0.5), 10, 50, 1)
		bullet27mm.transform = muzzle.global_transform
		bullet27mm.find_child("Sprite2D").scale.x = 2.0
		gun_ammo -= 1
		if is_shooting == false:
			break

func enemy_damage(damage: int):
	health -= damage
