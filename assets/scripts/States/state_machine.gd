extends Node

@export var initial_state: State
@export var turret_initial_state: State

#When additional vehicles are added, create a state thats some "menu state", where you're in no vehicle
var current_state: State
var states: Dictionary = {}

#loops through states, assigns each state in the dictionary a number
func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned_state.connect(on_child_transition)
	
	if initial_state:
		initial_state.enter_state()
		current_state = initial_state

func _process(delta):
	if current_state:
		current_state.Update(delta)

func _physics_process(delta):
	if current_state:
		current_state.Physics_Update(delta)

#makes the current_state the new_state
func on_child_transition(state, new_state_name):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state.exit_state()
	
	new_state.enter_state()
	
	current_state = new_state
