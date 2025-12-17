extends State
class_name Rotate_Heli_Right

@onready var heli: Helicopter = $"../.."
@onready var body: AnimatedSprite2D = $"../../Body"
@onready var tail_rotor: Sprite2D = $"../../Body/TailRotor"
@onready var nose_minigun: Sprite2D = $"../../Body/NoseMinigun"

func enter_state():
	heli.is_rotating = true
	tail_rotor.visible = false
	nose_minigun.visible = false
	body.play()
	await body.animation_finished
	heli.is_rotating = false
	tail_rotor.visible = true
	nose_minigun.visible = true
	transitioned_state.emit(self, "Flying_Right")
