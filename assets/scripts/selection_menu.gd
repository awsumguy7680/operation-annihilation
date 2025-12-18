class_name Selection_Menu extends Control

@onready var selected_vehicle_type: TextureRect = $SelectedVehicleType
@onready var vehicle_name: Label = $VehicleName
@onready var vehicle_specific_name: Label = $Menu/NamePanel/VehicleSpecificName
@onready var weapons_selector: HBoxContainer = $Menu/WeaponsSelectorPanel/WeaponsSelector
@onready var option_names: HBoxContainer = $Menu/WeaponsSelectorPanel/OptionNames
@onready var description: Label = $Menu/DescriptionPanel/Description
@onready var spec_values_1: Label = $Menu/SpecValuesPanel/SpecValues1
@onready var spec_values_2: Label = $Menu/SpecValuesPanel/SpecValues2
@onready var score_label: Label = $ScoreLabel
var tank_sprite = preload("res://assets/sprites/UMBT-1.png.png")
var helicopter_sprite = preload("res://assets/sprites/AH-7NimbleBird.png")
var ah7_pylon_sprite = preload("res://assets/sprites/AH-7Pylon.png")

var vehicle_types: Array = ["Tank", "Helicopter"]
var weapon_hardpoints: Dictionary = {}
var selected_weapons: Dictionary = {}
var hardpoints: Dictionary = {}
var current_vehicle_key = 0
var current_vehicle = "Tank"

func _ready():
	PlayerVehicleLoader.assign_selected("Tank")
	PlayerVehicleLoader.loadout = {}
	score_label.text = "SCORE: " + str(GameMaster.score)

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
		create_hardpoint(Vector2(1110, 1400), "OuterPylon", 1)
		create_hardpoint(Vector2(1110, 1325), "InnerPylon", 2)
		var outer_pylon_options: Array = ["Minigun", "GTGM", "AIM-12", "RKT-25"]
		create_weapon_selector("OuterPylon", outer_pylon_options)
		var inner_pylon_options: Array = ["GTGM x4", "AGM-90", "RKT-50", "RKT-25"]
		create_weapon_selector("InnerPylon", inner_pylon_options)
		selected_vehicle_type.texture = helicopter_sprite
		selected_vehicle_type.position = Vector2(161.0, -101.0)
		var pylon = Sprite2D.new()
		selected_vehicle_type.add_child(pylon)
		pylon.texture = ah7_pylon_sprite
		pylon.position = Vector2(1280.0, 1280.0)
		pylon.z_index = 2
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
	hardpoints[hardpointname] = hardpoint
	var sprite = Sprite2D.new()
	sprite.name = "WeaponSprite"
	hardpoint.add_child(sprite)

#Adds the selector dropdown menus for weapons
func create_weapon_selector(selectorname, options: Array):
	var option = OptionButton.new()
	var option_label = Label.new()
	weapons_selector.add_child(option)
	option_names.add_child(option_label)
	option.name = selectorname
	option.item_selected.connect(_on_weapon_option_selected.bind(selectorname))
	option.custom_minimum_size = Vector2(150.0, 40.0)
	option.alignment = HORIZONTAL_ALIGNMENT_CENTER
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	option.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	option.expand_icon = true
	option_label.text = selectorname
	option_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_FILL
	option_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	option_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	option_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	option.add_item("Empty", 0)
	for i in options:
		option.add_item(i)
	selected_weapons[selectorname] = "Empty"
	weapon_hardpoints[selectorname] = option
	PlayerVehicleLoader.loadout = selected_weapons

#Deletes all everything for when you switch to a different vehicle
func delete_hardpoints_and_selectors():
	for i in selected_vehicle_type.get_children():
		if i is Marker2D or Sprite2D:
			i.queue_free()
	for v in weapons_selector.get_children():
		if v is OptionButton:
			v.queue_free()
	for j in option_names.get_children():
		if j is Label:
			j.queue_free()
	weapon_hardpoints.clear()
	selected_weapons.clear()
	PlayerVehicleLoader.loadout.clear()

func _on_weapon_option_selected(index:int, selectorname: String):
	var button: OptionButton = weapon_hardpoints[selectorname]
	var selected = button.get_item_text(index)
	
	selected_weapons[selectorname] = selected
	PlayerVehicleLoader.loadout = selected_weapons
	
	update_weapon_preview(selectorname, selected)

func update_weapon_preview(hardpoint_name, weapon_name):
	if hardpoints.has(hardpoint_name):
		var hardpoint = hardpoints[hardpoint_name]
		var sprite = hardpoint.get_node("WeaponSprite")
		
		if weapon_name == "Empty":
			sprite.texture = null
			return
		else:
			sprite.texture = Preloader.weapon_previews[weapon_name]

#Start Game
func _on_deploy_button_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/operation_annihilation.tscn")
