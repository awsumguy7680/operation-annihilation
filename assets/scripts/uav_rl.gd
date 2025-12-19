extends Area2D

const SPEED = 2000.0
const STOP_DISTANCE: float = 2000
const GUN_SHOOT_DISTANCE: float = 6000.0
const RKT_SHOOT_DISTANCE: float = 10000.0
var ROCKET = Preloader.MISSILE
var BULLET = Preloader.BULLET
const BULLET_SPRITE = preload("res://assets/sprites/MGTracerGreen.png")
const ROCKET_SPRITE = Preloader.UAV_R1_ROCKET_SPRITES

#stats
@export var health: int
@export var armor: int
@export var gun_ammo: int
@export var rocket_ammo: int
@export var value: int
@export var facing_left: bool
var on_cooldown = false
var is_shooting = false
var past_max_gun_angle = false
var flared = false
var ammo

#Variables for nodes
var player_target = null
@onready var body: AnimatedSprite2D = $Body
@onready var tail_rotor: Sprite2D = $Body/TailRotor
@onready var gun: AnimatedSprite2D = $Body/Gun
@onready var barrel: Marker2D = $Body/Gun/Barrel
@onready var rocket_barrel: Marker2D = $Body/RocketBarrel
@onready var hitbox: CollisionPolygon2D = $Hitbox
@onready var main_scene = get_tree().current_scene

func _ready():
	if facing_left:
		body.flip_h = true
		tail_rotor.flip_h = true
		tail_rotor.offset.x = -5.0
		tail_rotor.position.x = 445.0
		tail_rotor.z_index = -1
		hitbox.scale.x = -1.0
		gun.flip_v = true
		gun.offset.y = -5.0
		gun.position.x = -285.0
		barrel.position.x = -121.0
		rocket_barrel.position.x = -165.0
		rocket_barrel.rotation_degrees = 180.0

func _process(delta: float):
	ammo = gun_ammo + rocket_ammo
	
	if facing_left:
		tail_rotor.rotation_degrees += 30
	else:
		tail_rotor.rotation_degrees -= 30
	
	if health > 0:
		if player_target:
			var distance = global_position.distance_to(player_target.global_position)
			
			gun.look_at(player_target.global_position)
			if facing_left:
				if gun.rotation_degrees <= 74.0  or gun.rotation_degrees >= 218.5:
					past_max_gun_angle = true
				else:
					past_max_gun_angle = false
				gun.rotation_degrees = clamp(gun.rotation_degrees, 74.0, 218.5)
			else:
				if gun.rotation_degrees <= -38.5 or gun.rotation_degrees >= 106.0:
					past_max_gun_angle = true
				else:
					past_max_gun_angle = false
				gun.rotation_degrees = clamp(gun.rotation_degrees, -38.5, 106.0)
			
			if distance >= STOP_DISTANCE:
				if facing_left:
					position.x -= SPEED * delta
				else:
					position.x += SPEED * delta
			else:
				position.x = position.x
			
			if distance <= GUN_SHOOT_DISTANCE and is_shooting == false and gun_ammo > 0 and not past_max_gun_angle:
				is_shooting = true
				gun.animation = "firing"
				gun.play()
				mg_shooting()
			elif distance >= GUN_SHOOT_DISTANCE or gun_ammo <= 0 or past_max_gun_angle:
				is_shooting = false
				gun.animation = "default"
				gun.stop()
				
			if distance <= RKT_SHOOT_DISTANCE and not on_cooldown and rocket_ammo > 0 and player_target is Player_Tank:
				rocket_ammo -= 1
				on_cooldown = true
				var rocket_instance = ROCKET.instantiate()
				owner.add_child(rocket_instance)
				rocket_instance.transform = rocket_barrel.global_transform
				rocket_instance.custom_missile_static_properties(ROCKET_SPRITE, Vector2(0.0, 5.0), Vector2(100.0, 10.0), Vector2(0.0, 0.0), 5, null)
				rocket_instance.custom_missile_handler(false, 10, "OPTICAL", player_target, 13000, 5, 1, 0.5, true)
				await get_tree().create_timer(0.1, false).timeout
				on_cooldown = false
		else:
			for child in main_scene.get_children():
				if child is CharacterBody2D:
					player_target = child
					break
	else:
		for child in get_children():
			child.visible = false
		GameMaster.add_score(value)
		queue_free()
		return

func mg_shooting():
	for i in gun_ammo:
		if is_shooting and health > 0 and get_tree().current_scene.name == "MainScene":
			await get_tree().create_timer(0.1, false).timeout
			var bullet556: Bullet = BULLET.instantiate()
			owner.add_child(bullet556)
			if bullet556:
				bullet556.custom_bullet(7000, 1, false, true, BULLET_SPRITE, Vector2(100, 10), Vector2(-60, -55), 10, 5, 1.5)
			bullet556.transform = barrel.global_transform
			gun_ammo -= 1
		else:
			break

func enemy_damage(damage: int):
	health -= damage
