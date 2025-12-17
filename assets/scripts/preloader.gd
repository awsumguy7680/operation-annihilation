extends Node

const BULLET = preload("res://assets/bullet.tscn")
const MISSILE = preload("res://assets/missile.tscn")
const TANK = preload("res://assets/Tank.tscn")
const HELI = preload("res://assets/Helicopter.tscn")

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
