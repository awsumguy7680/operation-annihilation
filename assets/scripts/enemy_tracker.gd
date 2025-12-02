extends Node

var enemies: bool = 0
var enemies_list: Dictionary = {}

func _ready():
	for child in self.get_parent().get_children():
		if child.is_in_group("Enemies"):
			enemies_list[child.name] = child
	print(enemies_list)
