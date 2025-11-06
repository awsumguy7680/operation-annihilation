class_name Missile extends Area2D

# "The missile knows where it is at all times, it knows this because it knows where it isn't"

#Self Vars
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
var is_active = false
var speed
var lift
var player_missile

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

func custom_missile_handler(is_plr, msl_track, tgt, spd, dmg, burn, delta, burnout_frame) -> void:
	#Custom parameters, allowing many custom missile types
	#is_plr determines if the missile is player of enemy launched
	#missile_track determines the guidance method.
	#guidance methods are "OPTICAL", "LASER" (Mouse following), "IR", "RADAR"
	#DONT CHANGE delta
	player_missile = is_plr
	var guidance = msl_track
	var target = tgt
	speed = spd
	var damage = dmg
	var burn_time = burn
	
	is_active = true
	
	animated_sprite_2d.play()
	await get_tree().create_timer(burn_time).timeout
	animated_sprite_2d.stop()
	animated_sprite_2d.sprite_frames = burnout_frame

func _process(delta: float) -> void:
	if is_active == true:
		if player_missile:
			pass
		elif not player_missile:
			lift = speed * 1.5
			position += transform.x * speed * delta
			position += transform.y * gravity * delta / lift
			gravity
