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
var weapon_previews: Dictionary = {
	"Empty": null,
	"Minigun": preload("res://assets/sprites/MountedMinigun.png"),
	"GTGM": preload("res://assets/sprites/GTGM.png"),
	"RKT-25": preload("res://assets/sprites/RKT25Pod.png"),
	"RKT-50": preload("res://assets/sprites/RKT50Pod.png"),
	"AIM-12": preload("res://assets/sprites/AIM12.png"),
	"AGM-90": preload("res://assets/sprites/AGM90.png"),
	"GTGM x4": preload("res://assets/sprites/GTGMx4.png")
}

const GTGM_MISSILE_SPRITES = preload("res://assets/sprites/UMBT_GTGM_Sprite_Frames.tres")

#Weapons
#var weapon_scenes: Dictionary = {
	#"GTGM": MISSILE.instantiate()
#}

#Music
const MENU_THEME = preload("res://assets/sounds/Music/new_1_2025-09-21_0251.wav")
const SELECTION_THEME = preload("res://assets/sounds/Music/CoffeebrewedinTimesofWar.wav")
const TANK_THEME = preload("res://assets/sounds/Music/mammoth.wav")
const HELI_THEME = preload("res://assets/sounds/Music/JammedwithLimbshigh.wav")
const JET_THEME = preload("res://assets/sounds/Music/destoroya.wav")

#SFX
const ROCKETMOTORLOOP = preload("res://assets/sounds/rocketmotorloop.mp3")
