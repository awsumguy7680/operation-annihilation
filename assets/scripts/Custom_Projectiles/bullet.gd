class_name Bullet extends Area2D

# "I have yet to meet one who can outsmart bullet"

@export var is_player_bullet: bool
@export var can_deflect: bool
@export var speed: int
@export var damage: int
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@export var despawn_time: int
@export var deflect_chance: int

#Bullet Handlers
func custom_bullet(spd, dmg, is_plr, deflect, sprite, hitbox, offset, despawn, chance):
	#Parameters for custom bullets
	#is_plr is asking whether the bullet is one fired by the player or an enemy
	#deflects is asking whether the bullet can deflect off armor or not
	#hitbox is a Vector2 that determines the size of the hitbox to match the sprite
	#offset is a Vector2 that determines the offset of the bullet sprite so it's centered
	#despawn sets despawn time
	#chance only needs to be assigned if deflect is true, this determines the chance of deflection
	speed = spd
	damage = dmg
	is_player_bullet = is_plr
	can_deflect = deflect
	despawn_time = despawn
	
	if sprite_2d:
			sprite_2d.texture = sprite
			sprite_2d.offset = offset
	
	if can_deflect == true:
		deflect_chance = chance
	
	if collision_shape_2d:
		if collision_shape_2d.shape is RectangleShape2D:
			(collision_shape_2d.shape as RectangleShape2D).size = hitbox
		
	
	
func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta
	await get_tree().create_timer(despawn_time).timeout
	queue_free()

#body_enetered is for if the bullet is fired by an enemy
func _on_body_entered(body: Node2D) -> void:
	if not is_player_bullet:
		if body is CharacterBody2D:
			if can_deflect:
				var random_deflection_chance = randi_range(0, deflect_chance - 1)
				var random_deflection_angle = randi_range(-45, 45)
				if random_deflection_chance == 0:
					rotation_degrees += random_deflection_angle
					return
				else:
					body.damage(damage)
					queue_free()
			else:
				body.damage(damage)
				queue_free()
		else:
			queue_free()

#area_entered is for if the bullet is fired by the player
func _on_area_entered(area: Area2D) -> void:
	if is_player_bullet:
		if area.is_in_group("Enemies"):
			var enemy_node = area.get_parent()
			if enemy_node.has_method("enemy_damage"):
				enemy_node.enemy_damage(damage)
				queue_free()
