extends Node

@export var current_selected_vehicle = "Tank"
var current_loaded_vehicle = null
var loaded_vehicle = false
#var loadout: Dictionary = {}

const TANK = preload("res://assets/Tank.tscn")
const HELI = preload("res://assets/Helicopter.tscn")
const JET = preload("res://assets/sprites/Jet.tscn")

func assign_selected(vehicle_name: String):
	current_selected_vehicle = vehicle_name

func load_vehicle(vehicle_name: String):
	var main = get_tree().current_scene
	if vehicle_name == "Tank":
		current_loaded_vehicle = TANK.instantiate()
		main.add_child(current_loaded_vehicle)
	elif vehicle_name == "Helicopter":
		current_loaded_vehicle = HELI.instantiate()
		main.add_child(current_loaded_vehicle)
	elif vehicle_name == "Jet":
		current_loaded_vehicle = JET.instantiate()
		main.add_child(current_loaded_vehicle)

func _process(_delta):
	if not loaded_vehicle:
		for i in get_tree().get_root().get_children():
			if i.name == "MainScene":
				load_vehicle(current_selected_vehicle)
				loaded_vehicle = true
				break
	elif loaded_vehicle:
		if not is_instance_valid(current_loaded_vehicle):
			current_loaded_vehicle = null
			loaded_vehicle = null
