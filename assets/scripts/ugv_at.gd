extends Node2D

#Constants
const SPEED = 300
const MISSILE = preload("res://assets/missile.tscn")
const AT_MISSILE_SPRITE_FRAMES = preload("res://assets/sprites/AT_Missile_Sprite_Frames.tres")
const ROCKETMOTORLOOP = preload("res://assets/sounds/rocketmotorloop.mp3")

const STOP_DISTANCE: float = 5000.0
const SHOOT_DISTANCE: float = 20000.0

#Self Variables
var health = 100
@export var ammo = 4
var on_cooldown = false
var distance

#Variables for Nodes
var player_target = null
@export var facing_left = false
@onready var body_sprites: AnimatedSprite2D = $BodySprites
@onready var wreck: Sprite2D = $Wreck
@onready var turret: AnimatedSprite2D = $TurretSprite
@onready var collision_shape_2d: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var launch_sound: AudioStreamPlayer2D = $LaunchSound

#Setup
func _ready() -> void:
	for child in owner.get_children():
		if child is CharacterBody2D:
			player_target = child
			break
	if facing_left:
		body_sprites.scale.x = -1.0
		body_sprites.position.x = -40.0
		turret.flip_h = true
		turret.position.x = -111.0
		turret.z_index = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y = -160
	if health > 0:
		if player_target:
			distance = body_sprites.global_position.distance_to(player_target.global_position)
		
		#Makes launcher always point at the player
		if player_target:
			turret.look_at(player_target.position)
			if turret.rotation_degrees <= -7.3 and not facing_left:
				turret.rotation_degrees = -7.3
			elif turret.rotation_degrees >= 3.0 and not facing_left:
				turret.rotation_degrees = 3.0
			elif turret.rotation_degrees > 7.3 and facing_left:
				turret.rotation_degrees = 7.3
			elif turret.rotation_degrees <= -3.0 and facing_left:
				turret.rotation_degrees = -3.0
		
		# Checks distance between the vehicle and the player, stops within a certain distance.
		if distance >= STOP_DISTANCE:
			if facing_left:
				position.x -= SPEED * delta
			else:
				position.x += SPEED * delta
			body_sprites.play()
		else:
			position.x = position.x
			body_sprites.pause()
		
		#Starts shooting within a certain distance
		if distance <= SHOOT_DISTANCE and health > 0 and ammo > 0 and on_cooldown == false:
			ammo -= 1
			var missile_instance: Missile = MISSILE.instantiate()
			owner.add_child(missile_instance)
			missile_instance.transform = turret.global_transform
			if facing_left:
				missile_instance.rotation_degrees = 180
			turret.play()
			launch_sound.play()
			on_cooldown = true
			if missile_instance:
				missile_instance.custom_missile_static_properties(AT_MISSILE_SPRITE_FRAMES, Vector2(50, 85), Vector2(220, 50), Vector2(30, 0), 15, ROCKETMOTORLOOP)
				missile_instance.custom_missile_handler(false, 50, "OPTICAL", player_target, 10000, 200, 3, 2.0)
			await get_tree().create_timer(3).timeout
			on_cooldown = false
		elif distance > SHOOT_DISTANCE or health <= 0:
			pass
	else:
		body_sprites.visible = false
		turret.visible = false
		collision_shape_2d.disabled = true
		wreck.visible = true
		await get_tree().create_timer(4).timeout
		queue_free()
		return

func enemy_damage(damage: int) -> void:
	health -= damage
