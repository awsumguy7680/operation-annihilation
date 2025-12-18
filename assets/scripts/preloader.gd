extends Node

#Bodies
const BULLET = preload("res://assets/bullet.tscn")
const MISSILE = preload("res://assets/missile.tscn")
const TANK = preload("res://assets/Tank.tscn")
const HELI = preload("res://assets/Helicopter.tscn")
const UGV_MG = preload("res://assets/ugv_mg.tscn")
const UGV_AT = preload("res://assets/ugv_at.tscn")
const UGV_RFV = preload("res://assets/ugv_rfv.tscn")


#Sprites
const CROSS_GUN = preload("res://assets/sprites/Crosshair.png")
const CROSS_OPTICAL = preload("res://assets/sprites/MissileCrosshair.png")
const CROSS_LASER = preload("res://assets/sprites/LaserCrosshair.png")
const CROSS_IR = preload("res://assets/sprites/IRCrosshair.png")

#var weapon_previews: Dictionary = {
	#"Empty": null,
	#"Minigun": preload("res://assets/sprites/MountedMinigun.png"),
	#"GTGM": preload("res://assets/sprites/GTGM.png"),
	#"RKT-25": preload("res://assets/sprites/RKT25Pod.png"),
	#"RKT-50": preload("res://assets/sprites/RKT50Pod.png"),
	#"AIM-12": preload("res://assets/sprites/AIM12.png"),
	#"AGM-90": preload("res://assets/sprites/AGM90.png"),
	#"GTGM x4": preload("res://assets/sprites/GTGMx4.png")
#}

const SHELL125_SPRITE = preload("res://assets/sprites/UMBTShell.png")
const MINIGUN_BULLET_SPRITE = preload("res://assets/sprites/MinigunRound.png")
const GTGM_MISSILE_SPRITES = preload("res://assets/sprites/UMBT_GTGM_Sprite_Frames.tres")
const UAV_R1_ROCKET_SPRITES = preload("res://assets/sprites/UAV_R1_Sprite_Frames.tres")
const RKT_50_SPRITES = preload("res://assets/sprites/RKT50_Sprite_Frames.tres")
const AIM_12_SPRITES = preload("res://assets/sprites/AIM12_Sprite_Frames.tres")

#Weapons
#var weapon_scenes: Dictionary = {
	#"GTGM": MISSILE.instantiate()
#}

#HUD Icons
var APFSDS_ICON = preload("res://assets/sprites/TankShellHUDIcon.png")
var MINIGUN_ICON = preload("res://assets/sprites/MinigunHUDIcon.png")
var GTGM_ICON = preload("res://assets/sprites/GTGMHUDIcon.png")
var AIM12_ICON = preload("res://assets/sprites/AIM12Icon.png")
var RKT50_ICON = preload("res://assets/sprites/RKT50Icon.png")

#Music
const MENU_THEME = preload("res://assets/sounds/Music/new_1_2025-09-21_0251.wav")
const SELECTION_THEME = preload("res://assets/sounds/Music/CoffeebrewedinTimesofWar.wav")
const TANK_THEME = preload("res://assets/sounds/Music/mammoth.wav")
const HELI_THEME = preload("res://assets/sounds/Music/JammedwithLimbshigh.wav")
const JET_THEME = preload("res://assets/sounds/Music/destoroya.wav")

#SFX
const ROCKETMOTORLOOP = preload("res://assets/sounds/rocketmotorloop.mp3")
