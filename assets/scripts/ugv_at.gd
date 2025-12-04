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
var ammo = 4
var on_cooldown = false
var distance

#Variables for Nodes
@onready var body_sprites: AnimatedSprite2D = $BodySprites
@onready var wreck: Sprite2D = $Wreck
@onready var turret: AnimatedSprite2D = $TurretSprite
@onready var collision_shape_2d: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var character_body_2d: CharacterBody2D = $"../CharacterBody2D"
@onready var launch_sound: AudioStreamPlayer2D = $LaunchSound

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y = -160
	if health > 0:
		if character_body_2d:
			distance = body_sprites.global_position.distance_to(character_body_2d.global_position)
		
		#Makes launcher always point at the player
		if character_body_2d:
			turret.look_at(character_body_2d.position)
			if turret.rotation_degrees <= -7.3:
				turret.rotation_degrees = -7.3
			elif turret.rotation_degrees >= 3.0:
				turret.rotation_degrees = 3.0
		
		# Checks distance between the vehicle and the player, stops within a certain distance.
		if distance >= STOP_DISTANCE:
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
			turret.play()
			launch_sound.play()
			on_cooldown = true
			if missile_instance:
				missile_instance.custom_missile_static_properties(AT_MISSILE_SPRITE_FRAMES, Vector2(50, 85), Vector2(220, 50), Vector2(30, 0), 15, ROCKETMOTORLOOP)
				missile_instance.custom_missile_handler(false, 50, "OPTICAL", character_body_2d, 10000, 200, 3, 2.0)
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
