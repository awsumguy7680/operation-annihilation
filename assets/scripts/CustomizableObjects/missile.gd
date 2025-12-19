class_name Missile extends Area2D

# "The missile knows where it is at all times, it knows this because it knows where it isn't"

#Self Vars
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
#vars that get assigned in with missile parameters later
@export var is_active = false
@export var damage: int
@export var health: int
@export var target: Node = null
@export var locked_on: bool
@export var guidance: String
@export var thrust: float
@export var burn_time: int
@export var delete_time: int
@export var steer_force: float
var burnout_anim
var lift: float
var drag: float
var player_missile
var velocity = 0.0

#Missile handlers
func custom_missile_static_properties(msl_body, msl_body_offset: Vector2, collision_box: Vector2, collision_box_offset: Vector2, del: int, audio) -> void:
	#Custom parameters, allowing many custom missile types
	#del determines time for till missile deletes itself
	#current msl_body are "UGV_AT_MISSILE", "UMBT_GTGM"
	delete_time = del
	
	if audio != null:
		audio_stream_player_2d.stream = audio
	
	animated_sprite_2d.sprite_frames = msl_body
	animated_sprite_2d.offset = msl_body_offset
	animated_sprite_2d.animation = "default"
	
	await get_tree().process_frame
	if animated_sprite_2d.sprite_frames.has_animation("burnout"):
		burnout_anim = "burnout"
	
	if collision_shape_2d.shape is RectangleShape2D:
			(collision_shape_2d.shape as RectangleShape2D).size = collision_box
			collision_shape_2d.position = collision_box_offset

func custom_missile_handler(is_plr, hlth, msl_track, tgt, thrst, dmg, burn, steer, launch_immediately):
	#Custom parameters, allowing many custom missile types
	#is_plr determines if the missile is player of enemy launched
	#health is how tough the missile is, so can be destroyed/intercepted
	#missile_track determines the guidance method.
	#guidance methods are "OPTICAL", "LASER" (Mouse following), "IR", "RADAR"
	#Keep steer within ~5 or the missile will have insane manueverability
	health = hlth
	thrust = thrst
	player_missile = is_plr
	guidance = msl_track
	target = tgt
	damage = dmg
	steer_force = steer
	burn_time = burn
	
	if launch_immediately:
		launch()

#Call this to start the missile, otherwise it will do nothing
func launch():
	if is_active:
		return
	is_active = true
	delete()
	
	if not player_missile:
		if target is CharacterBody2D:
			target.msl_alert(true, self, guidance)
	
	audio_stream_player_2d.play()
	animated_sprite_2d.play("default")
	await get_tree().create_timer(burn_time, false).timeout
	audio_stream_player_2d.stop()
	animated_sprite_2d.play(burnout_anim)
	thrust = 0

#Deletes missile after a set amount of time
func delete():
	await get_tree().create_timer(delete_time, false).timeout
	if not player_missile:
		add_to_group("Enemy_Missiles")
		target.msl_alert(false, self, guidance)
	queue_free()

#Physics
func _physics_process(delta: float):
	#calculating all of the forces acting on a missile
	#there are 4 basic forces, lift, drag, thrust, gravity
	#thrust from the motor and gravity are constant (thrust is 0 once the motor burns out)
	#the total upward velocity depends on (lift + upward thrust) - gravity
	#the total horizontal velocity depends on thrust - drag
	#the AOA (rotation_degrees) combined with the horizontal velocity influences the amount of lift/drag.
	#for example a high AOA and high horizontal velocity = lots of drag
	
	if is_active:
		#var AOA = rotation_degrees
		
		#Vertical Forces (Lift/Gravity)
		#lift = (0.6 * velocity) / AOA
		
		global_position.y += (gravity/2) * delta
		
		#Horizontal Forces (Thrust/Drag)
		#drag = (0.8 * velocity) * AOA
		velocity += thrust * delta
		global_position += transform.x * velocity * delta

func _process(delta: float):
	#Track target and avoid terrain
	if is_active:
		if self != null and target != null:
			if guidance == "OPTICAL":
				if global_position.y < -250:
					var desired_angle = (target.global_position - global_position).angle()
					var angle_diff = wrapf(desired_angle - rotation, -PI, PI)
					var max_steer = steer_force * delta
					rotation += clamp(angle_diff, -max_steer, max_steer)
				else:
					var desired_angle = ((target.global_position - Vector2(INF, INF)) - global_position).angle()
					var angle_diff = wrapf(desired_angle - rotation, -PI, PI)
					var max_steer = steer_force * delta
					rotation += clamp(angle_diff, -max_steer, max_steer)
			if guidance == "IR":
				var desired_angle = (target.global_position - global_position).angle() + PI
				var angle_diff = wrapf(desired_angle - rotation, -PI, PI)
				var max_steer = steer_force * delta
				rotation += clamp(angle_diff, -max_steer, max_steer)
				#if not target.flared:
					#pass
				#else:
					#target = null
		elif self != null and target == null:
			if guidance == "LASER":
				var mouse_position = get_global_mouse_position()
				var desired_angle = (mouse_position - global_position).angle() + PI
				var angle_diff = wrapf(desired_angle - rotation, -PI, PI)
				var max_steer = steer_force * delta
				rotation += clamp(angle_diff, -max_steer, max_steer)
		elif target == null:
			return

#Body entered is for if the missile is fired by enemies
func _on_body_entered(body: Node2D) -> void:
	if is_active:
		if body is CharacterBody2D and not player_missile:
			body.damage(damage)
			target.msl_alert(false, self, guidance)
			queue_free()
		elif not player_missile:
			queue_free()
			if not player_missile:
				target.msl_alert(false, self, guidance)
		elif body is TileMapLayer:
			if not player_missile:
				target.msl_alert(false, self, guidance)
			queue_free()

#Area entered is for if the missile is fired by the player
func _on_area_entered(area: Area2D) -> void:
	if is_active:
		if area is Area2D and player_missile:
			if area.is_in_group("Enemies"):
				var enemy_node = area.get_parent()
				if enemy_node.has_method("enemy_damage"):
					enemy_node.enemy_damage(damage)
					queue_free()
				elif area.has_method("enemy_damage"):
					area.enemy_damage(damage)
					queue_free()
		elif player_missile:
			queue_free()

func missile_damage(dmge):
	if is_active:
		health -= dmge
		if health <= 0:
			if not player_missile:
				target.msl_alert(false, self, guidance)
			queue_free()
