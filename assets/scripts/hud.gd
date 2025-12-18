extends Control

#HUD elements
@onready var health_display: RichTextLabel = $Health
@onready var weapon_display: RichTextLabel = $WeaponDisplay
@onready var ammo_display: RichTextLabel = $Ammo
@onready var score_display: RichTextLabel = $Score
@onready var weapon_icon: TextureRect = $WeaponIcon
@onready var weapon_num: Label = $WeaponNum
@onready var msl_warning: VBoxContainer = $MslWarning
@onready var warning_label: Label = $MslWarning/WarningLabel
@onready var misc: RichTextLabel = $LaserCharge

var current_vehicle = null

func _process(_delta: float):
	score_display.text = "Score: " + str(GameMaster.score)
	if current_vehicle:
		if current_vehicle is Player_Tank:
			var apfsds_icon = preload("res://assets/sprites/TankShellHUDIcon.png")
			var minigun_icon = preload("res://assets/sprites/MinigunHUDIcon.png")
			var gtgm_icon = preload("res://assets/sprites/GTGMHUDIcon.png")
			health_display.text = "Health: " + str(current_vehicle.health)
			misc.visible = true
			misc.text = "Laser Charge: " + str(current_vehicle.laser_charge) + "%"
			weapon_display.text = current_vehicle.current_weapon
			weapon_num.text = str(current_vehicle.weapons.find(current_vehicle.current_weapon) + 1)
			if current_vehicle.current_weapon == "Cannon":
				ammo_display.text = "Cannon Ammo: " + str(current_vehicle.cannon_ammo)
				weapon_icon.texture = apfsds_icon
			elif current_vehicle.current_weapon == "GTGM":
				ammo_display.text = "AT Missiles: " + str(current_vehicle.GTGM_ammo)
				weapon_icon.texture = gtgm_icon
			elif current_vehicle.current_weapon == "Minigun":
				ammo_display.text = "Minigun Ammo: " + str(current_vehicle.minigun_ammo)
				weapon_icon.texture = minigun_icon
		elif current_vehicle is Helicopter:
			var minigun_icon = preload("res://assets/sprites/MinigunHUDIcon.png")
			health_display.text = "Health: " + str(current_vehicle.health)
			misc.visible = true
			misc.text = "Altitude: " + str(int(abs(current_vehicle.global_position.y) / 100) - 4) + "m"
			weapon_display.text = current_vehicle.current_weapon
			if current_vehicle.current_weapon == "Nose Minigun":
				weapon_icon.texture = minigun_icon
		
		#Missile Warnings
		if current_vehicle.incoming_missiles > 0:
			warning_label.visible = true
			for i in current_vehicle.incoming_missiles_by_type:
				if current_vehicle.incoming_missiles_by_type[i] > 0:
					warning_label.text = "MSL ALERT: " + i + " x" + str(current_vehicle.incoming_missiles_by_type[i])
			
		else:
			warning_label.visible = false
			

func death_screen():
	pass

func _on_main_scene_child_entered_tree(node: Node):
	if node is CharacterBody2D:
		current_vehicle = node

func _on_main_scene_child_exiting_tree(node: Node) -> void:
	if node is CharacterBody2D:
		current_vehicle = null
