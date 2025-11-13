class_name Missile extends Area2D

# "The missile knows where it is at all times, it knows this because it knows where it isn't"

#Self Vars
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
#A bunch of vars that get assigned in with missile parameters later
var is_active = false
var damage
var target
var thrust
var speed
var lift
var drag
var player_missile
var vertical_velocity
var horizontal_velocity

#Launchers
@onready var ugv_at: Node2D = $"."

#Missile handlers
func custom_missile_static_properties(msl_body, collision_box, del) -> void:
	#Custom parameters, allowing many custom missile types
	#del determines time for till missile deletes itself
	#current airframes are "UGV_AT_MISSILE", "UMBT_GTGM"
	var airframe = msl_body
	var hitbox = collision_box
	#var sound = _audio
	var delete_time = del
	
	animated_sprite_2d.sprite_frames = airframe
	collision_shape_2d.scale = hitbox
	#audio_stream_player_2d.stream = sound
	
	#Delete the missile after delete time
	await get_tree().create_timer(delete_time).timeout
	queue_free()

func custom_missile_handler(is_plr, msl_track, tgt, spd, thrst, dmg, burn, delta, burnout_frame) -> void:
	#Custom parameters, allowing many custom missile types
	#is_plr determines if the missile is player of enemy launched
	#missile_track determines the guidance method.
	#guidance methods are "OPTICAL", "LASER" (Mouse following), "IR", "RADAR"
	#DONT CHANGE delta
	player_missile = is_plr
	var guidance = msl_track
	target = tgt
	speed = spd
	thrust = thrst
	damage = dmg
	var burn_time = burn
	
	is_active = true
	
	horizontal_velocity
	
	animated_sprite_2d.play()
	await get_tree().create_timer(burn_time).timeout
	animated_sprite_2d.stop()
	animated_sprite_2d.sprite_frames = burnout_frame

func _physics_process(delta: float):
	pass
	#calculating all of the forces acting on a missile
	#there are 4 basic forces, lift, drag, thrust, gravity
	#thrust from the motor and gravity are constant (thrust is 0 once the motor burns out)
	#the total upward velocity depends on (lift + upward thrust) - gravity
	#the total horizontal velocity depends on thrust - drag
	#the AOA (rotation_degrees) combined with the horizontal velocity influences the amount of lift/drag.
	#for example a high AOA and high horizontal velocity = lots of drag
	
	#var AOA = abs(global_rotation_degrees)
	#var drag = (vertical_velocity * 0.1) * AOA
	#lift = (horizontal_velocity/10) - drag
	#var vertical_velocity = lift - gravity
	#var horizontal_velocity = speed * speed


func _process(delta: float) -> void:
	if is_active == true:
		if player_missile:
			pass
		elif not player_missile:
			position.x += speed * delta
			#position.x = move_toward(position.x, target.global_position, speed)
			#position.y = move_toward(position.y, -100.0, vertical_velocity)

func _on_body_entered(body: Node2D):
	if body is CharacterBody2D:
		body.damage(damage)
		queue_free()
