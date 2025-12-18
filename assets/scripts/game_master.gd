extends Node

@export var nuclear_threshold: int
var score = 0
var wave = 1
var enemies_properties: Dictionary = {}
#var enemies_health: Dictionary = {}
#var enemies_positions: Dictionary = {}
#var enemies_ammos: Dictionary = {}

func add_score(val):
	score += val
	if score > nuclear_threshold:
		print("nukes ready")

#func _process(_delta: float):
	#if get_tree().current_scene.name == "MainScene":
		#var enemies = get_tree().get_nodes_in_group("Enemy_Vehicles")
		#for i in enemies:
			#if not enemies.has(i):
				#enemies_properties[i] = [i.health, i.ammo, i.global_position]
		#print(enemies_properties)

#func _add_enemies()
	#
