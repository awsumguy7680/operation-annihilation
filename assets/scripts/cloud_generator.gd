extends Node

@export var num_clouds: int
@export var cloud_speed: float
@onready var main_scene: Node2D = $".."
var clouds_list: Array = []

const CLOUD1 = preload("res://assets/sprites/Cloud1.png")
const CLOUD2 = preload("res://assets/sprites/Cloud2.png")
const CLOUD3 = preload("res://assets/sprites/Cloud3.png")

func _ready():
	for i in num_clouds:
		var cloud_sprite = Sprite2D.new()
		var random_cloud = randi_range(0, 2)
		var random_x = randi_range(-100000, 100000)
		var random_y = randi_range(-50000, -2000)
		if random_cloud == 0:
			cloud_sprite.texture = CLOUD1
		elif random_cloud == 1:
			cloud_sprite.texture = CLOUD2
		elif random_cloud == 2:
			cloud_sprite.texture = CLOUD3
		cloud_sprite.name = "Cloud" + str(i)
		cloud_sprite.scale = Vector2(10.0, 10.0)
		cloud_sprite.z_index = -9
		main_scene.add_child.call_deferred(cloud_sprite)
		cloud_sprite.global_position = Vector2(random_x, random_y)
		clouds_list.append(cloud_sprite)

func _process(_delta: float):
	for cloud in clouds_list:
		if cloud is Sprite2D:
			cloud.global_position.x += cloud_speed
			if cloud.global_position.x > 100000:
				cloud.global_position.x = -100000
