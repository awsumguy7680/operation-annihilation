class_name Rocket_Pod extends Node2D

var MISSILE = Preloader.MISSILE

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var rockets: int
var rocket_name: String
var rocket_static_properties: Array = []
var rocket_handler_properties: Array = []
var is_rotating = false

func setup(animation: SpriteFrames, ammo: int, type: String, static_properties: Array, handler_properties: Array):
	animated_sprite_2d.sprite_frames = animation
	rockets = ammo
	rocket_name = type
	rocket_static_properties = static_properties
	handler_properties = handler_properties

func shoot():
	if is_rotating == false:
		animated_sprite_2d.animation = "shoot"
		animated_sprite_2d.play()
		var rocket = MISSILE.instantiate()
		get_tree().current_scene.add_child(rocket)
		rocket.callv("custom_missile_static_properties", rocket_static_properties)
		rocket.callv("custom_missile_handler", rocket_handler_properties)
