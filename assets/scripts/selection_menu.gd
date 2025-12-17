extends Control

@onready var selected_vehicle_type: TextureRect = $SelectedVehicleType
@onready var vehicle_name: Label = $VehicleName
@onready var vehicle_specific_name: Label = $Menu/NamePanel/VehicleSpecificName
@onready var weapons_selector: HBoxContainer = $Menu/WeaponsSelectorPanel/WeaponsSelector
@onready var description: Label = $Menu/DescriptionPanel/Description
@onready var spec_values_1: Label = $Menu/SpecValuesPanel/SpecValues1
@onready var spec_values_2: Label = $Menu/SpecValuesPanel/SpecValues2
var tank_sprite = preload("res://assets/sprites/UMBT-1.png.png")
var helicopter_sprite = preload("res://assets/sprites/AH-7NimbleBird.png")

var vehicle_types: Array = ["Tank", "Helicopter"]
var current_vehicle_key = 0
var current_vehicle = "Tank"
var weapon_options = 0

func _ready():
	PlayerVehicleLoader.assign_selected("Tank")

#Return to Main Menu
func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/main_menu.tscn")

#Vehicle Type Selection
func _on_select_r_pressed() -> void:
	current_vehicle_key += 1
	if current_vehicle_key > 1: #When adding the jet set to 2
		current_vehicle_key = 0
		current_vehicle = vehicle_types[0]
	else:
		current_vehicle = vehicle_types[current_vehicle_key]
	set_vehicle(current_vehicle)

func _on_select_l_pressed() -> void:
	current_vehicle_key -= 1
	if current_vehicle_key < 0:
		current_vehicle_key = 1
		current_vehicle = vehicle_types[1]
	else:
		current_vehicle = vehicle_types[current_vehicle_key]
	set_vehicle(current_vehicle)

func set_vehicle(vehicle: String):
	PlayerVehicleLoader.assign_selected(vehicle)
	if vehicle == "Tank":
		delete_hardpoints_and_selectors()
		selected_vehicle_type.texture = tank_sprite
		selected_vehicle_type.position = Vector2(150.0, -74.0)
		vehicle_name.text = "TANK: UMBT"
		vehicle_specific_name.text = "UMBT"
		description.text = "The UMBT is a 
		semi-autonamous
		main battle tank built for 
		combat in the age of drone
		warfare"
		spec_values_1.text = "Mass: 55 Tons
		Engine: Turbine/Electric Hybrid
		Cannon: 120mm Smoothbore
		MG: 5.56 M134 Minigun
		Missile: GTGM
		"
		spec_values_2.text = "HP: 5000
		Top Speed: 60km/h
		Countermeasures: IR Smoke
		Crew: 1-2
		Designed: 2030"
	elif vehicle == "Helicopter":
		delete_hardpoints_and_selectors()
		create_hardpoint(Vector2(1110, 1400), "Outer Pylon", 1)
		create_hardpoint(Vector2(1110, 1325), "Inner Pylon", -1)
		selected_vehicle_type.texture = helicopter_sprite
		selected_vehicle_type.position = Vector2(161.0, -101.0)
		vehicle_name.text = "HELICOPTER: AH-7 NIMBLE BIRD"
		vehicle_specific_name.text = "AH-7"
		description.text = "The AH-7 'Nimble Bird' is a fast 
		and manueverable light attack
		helicopter. It can saturate 
		enemies with firepower
 		but it's vulnerable to missiles.
		"
		spec_values_1.text = "Dry Mass: 0.975t
		Engine: 2x Turboshaft engine
		MG: 5.56 M134 Minigun
		Missile: Rockets, Optical/IR MSL
		HP: 1500"
		spec_values_2.text = "Top Speed: 320km/h
		Service Ceiling: 7,000m
		Countermeasures: Flares
		Crew: 2
		Designed: 2027"

#Adds a single hardpoint, call multiple times
func create_hardpoint(pos: Vector2, hardpointname: String, zindex: int):
	var hardpoint = Marker2D.new()
	selected_vehicle_type.add_child(hardpoint)
	hardpoint.position = pos
	hardpoint.name = hardpointname
	hardpoint.z_index = zindex

func create_weapon_selector(selectorname):
	pass

func delete_hardpoints_and_selectors():
	for i in selected_vehicle_type.get_children():
		if i is Marker2D:
			i.queue_free()
	for v in weapons_selector.get_children():
		if v is OptionButton:
			v.queue_free()

#Start Game
func _on_deploy_button_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/operation_annihilation.tscn")
