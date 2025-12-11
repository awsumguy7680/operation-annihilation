extends Node

@export var current_selected_vehicle = "Tank"
var loaded_vehicle = false

const tank = preload("res://assets/Tank.tscn")
const heli = preload("res://assets/Helicopter.tscn")

func assign_selected(vehicle_name: String):
	current_selected_vehicle = vehicle_name

func load_vehicle(vehicle_name: String):
	var main = get_tree().current_scene
	if vehicle_name == "Tank":
		var vehicle = tank.instantiate()
		main.add_child(vehicle)
	elif vehicle_name == "Helicopter":
		var vehicle = heli.instantiate()
		main.add_child(vehicle)

func _process(_delta):
	if not loaded_vehicle:
		for i in get_tree().get_root().get_children():
			if i.name == "MainScene":
				load_vehicle(current_selected_vehicle)
				loaded_vehicle = true
				break
	else:
		if get_tree().current_scene.name != "MainScene":
			for child in get_tree().current_scene.get_children():
				if child is CharacterBody2D:
					child.queue_free()
					break
		#else:
			#print("dormant")
