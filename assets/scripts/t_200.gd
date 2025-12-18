extends Area2D

#Constants
const SPEED = 200
const STOP_DISTANCE: float = 6000
const CANNON_SHOOT_DISTANCE: float = 12000.0
const MSL_SHOOT_DISTANCE: float = 15000.0
const MG_SHOOT_DISTANCE: float = 8000.0
var BULLET = Preloader.BULLET
var MISSILE = Preloader.MISSILE
#const MG_BULLET_SPRITE = 

@onready var turret: AnimatedSprite2D = $Turret
@onready var main_gun: AnimatedSprite2D = $Turret/MainGun
@onready var cannon_muzzle_flash: AnimatedSprite2D = $Turret/MainGun/CannonMuzzleFlash
@onready var mg: AnimatedSprite2D = $Turret/MG
@onready var chassis: AnimatedSprite2D = $Chassis
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var wreck: Sprite2D = $Wreck

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

func _process(_delta: float):
	pass

func enemy_damage(damage: int):
	health -= damage
