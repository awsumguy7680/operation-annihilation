extends Area2D

const CHANCE = 5

var speed = 8000
var damage = 1

#Gives the bullet velocity and deletes it after 10 seconds
func _physics_process(delta):
	position += transform.x * speed * delta
	await get_tree().create_timer(10).timeout
	queue_free()

#If the bullet hits the player it either does damage and then is deleted, or is deflected.
func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		var random_deflection_chance = randi_range(0, CHANCE - 1)
		var random_deflection_angle = randi_range(-45, 45)
		if random_deflection_chance == 0:
			rotation_degrees += random_deflection_angle
			return
		else:
			body.damage(damage)
			queue_free()
