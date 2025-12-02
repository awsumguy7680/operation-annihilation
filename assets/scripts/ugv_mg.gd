extends Node2D

#Constants
const SPEED = 300
const STOP_DISTANCE: float = 5000.0
const SHOOT_DISTANCE: float = 7000.0

#Self Variables
var is_shooting = false
var health = 100
var ammo = 1000
var distance

#Variables for nodes
@onready var body_sprites: AnimatedSprite2D = $BodySprites
@onready var wreck: Sprite2D = $Wreck
@onready var turret: Sprite2D = $TurretSprite
@onready var muzzle_flash_sprite: AnimatedSprite2D = $TurretSprite/MuzzleFlashSprite
@onready var collision_shape_2d: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var hitbox: Area2D = $Hitbox
@onready var character_body_2d: CharacterBody2D = $"../CharacterBody2D"
@onready var main_scene: Node2D = $".."
@onready var muzzle: Marker2D = $TurretSprite/Muzzle
@onready var firing_sound: AudioStreamPlayer2D = $TurretSprite/Muzzle/FiringSound
const BULLET = preload("res://assets/bullet.tscn")
const BULLET_SPRITE = preload("res://assets/sprites/MGTracerGreen.png")

# Called when the node enters the scene tree for the first time.
func _process(delta: float) -> void:
	position.y = -160
	if health > 0:
		if character_body_2d:
			distance = body_sprites.global_position.distance_to(character_body_2d.global_position)
		
		#Makes MG turret always point at the player
		if character_body_2d:
			turret.look_at(character_body_2d.position)
		
		# Checks distance between the vehicle and the player, stops within a certain distance.
		if distance >= STOP_DISTANCE:
			position.x += SPEED * delta
			body_sprites.play()
		else:
			position.x = position.x
			body_sprites.pause()
		
		#Starts shooting within a certain distance
		if distance <= SHOOT_DISTANCE and is_shooting == false and ammo > 0:
			is_shooting = true
			muzzle_flash_sprite.play()
			firing_sound.play()
			shooting()
		elif distance > SHOOT_DISTANCE or ammo <= 0:
			firing_sound.stop()
			muzzle_flash_sprite.stop()
			is_shooting = false
			return
	else:
		is_shooting = false
		firing_sound.stop()
		muzzle_flash_sprite.stop()
		body_sprites.visible = false
		turret.visible = false
		collision_shape_2d.disabled = true
		wreck.visible = true
		await get_tree().create_timer(4).timeout
		queue_free()
		return

#Handles shooting bullets
func shooting():
	for i in ammo:
		var random_rotation = randi_range(-2, 2)
		await get_tree().create_timer(0.1).timeout
		var bullet_instance: Bullet = BULLET.instantiate()
		owner.add_child(bullet_instance)
		if bullet_instance:
			bullet_instance.custom_bullet(8000, 1, false, true, BULLET_SPRITE, Vector2(100, 10), Vector2(-60, -55), 10, 5)
		muzzle.rotation_degrees = random_rotation
		bullet_instance.transform = muzzle.global_transform
		ammo -= 1
		if is_shooting == false:
			break

func enemy_damage(damage: int) -> void:
	health -= damage
