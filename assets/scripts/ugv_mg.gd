extends Node2D

#Constants
const SPEED = 300
const STOP_DISTANCE: float = 5000.0
const SHOOT_DISTANCE: float = 7000.0
var BULLET = Preloader.BULLET
const BULLET_SPRITE = preload("res://assets/sprites/MGTracerGreen.png")

#Self Variables
var is_shooting = false
@export var health: int
@export var armor: int
@export var ammo: int
@export var value: int
@export var facing_left: bool

#Variables for nodes
var player_target = null
@onready var body_sprites: AnimatedSprite2D = $BodySprites
@onready var wreck: Sprite2D = $Wreck
@onready var turret: Sprite2D = $TurretSprite
@onready var muzzle_flash_sprite: AnimatedSprite2D = $TurretSprite/MuzzleFlashSprite
@onready var collision_shape_2d: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var hitbox: Area2D = $Hitbox
@onready var main_scene: Node2D = $".."
@onready var muzzle: Marker2D = $TurretSprite/Muzzle
@onready var firing_sound: AudioStreamPlayer2D = $TurretSprite/Muzzle/FiringSound

#Setup
func _ready():
	if facing_left:
		body_sprites.scale.x = -1.0
		body_sprites.position.x = -40.0
		turret.flip_h = true
		const MIRRORED_TURRET_SPRITE = preload("res://assets/sprites/UGV-MG(TurretMirrored).png")
		turret.texture = MIRRORED_TURRET_SPRITE
	
# Called when the node enters the scene tree for the first time.
func _process(delta: float):
	position.y = -160
	
	if health > 0:
		if player_target:
			var distance = body_sprites.global_position.distance_to(player_target.global_position)
		
			#Makes MG turret always point at the player
			if player_target:
				turret.look_at(player_target.position)
			
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
			for child in main_scene.get_children():
				if child is CharacterBody2D:
					player_target = child
					break
	else:
		is_shooting = false
		firing_sound.stop()
		muzzle_flash_sprite.stop()
		body_sprites.visible = false
		turret.visible = false
		collision_shape_2d.disabled = true
		wreck.visible = true
		await get_tree().create_timer(4, false).timeout
		GameMaster.add_score(value)
		queue_free()
		return

#Handles shooting bullets
func shooting():
	if player_target != null:
		for i in ammo:
			await get_tree().create_timer(0.1, false).timeout
			var bullet_instance: Bullet = BULLET.instantiate()
			owner.add_child(bullet_instance)
			if bullet_instance:
				bullet_instance.custom_bullet(8000, 1, false, true, BULLET_SPRITE, Vector2(100, 10), Vector2(-60, -55), 10, 10, 2.0)
			bullet_instance.transform = muzzle.global_transform
			ammo -= 1
			if is_shooting == false:
				break

func enemy_damage(damage: int):
	health -= damage
