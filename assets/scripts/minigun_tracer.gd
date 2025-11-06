extends Area2D

var speed = 9000
var damage = 5

#Gives the bullet velocity and deletes it after 10 seconds
func _physics_process(delta):
	position += transform.x * speed * delta
	await get_tree().create_timer(5).timeout
	queue_free()

#If the bullet hits an enemy it does damage and then is deleted
func _on_area_entered(body: Area2D) -> void:
	if body.get_parent().has_method("enemy_damage"):
		body.get_parent().enemy_damage(damage)
		queue_free()
