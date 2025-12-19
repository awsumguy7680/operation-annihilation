extends State
class_name Flip_Mirrored

@onready var jet: Jet = $"../.."
@onready var body: AnimatedSprite2D = $"../../Body"
@onready var elevator: Sprite2D = $"../../Body/Elevator"

func enter_state():
	jet.is_rotating = true
	elevator.visible = false
	body.animation = "rotation"
	body.play()
	await body.animation_finished
	jet.is_rotating = false
	elevator.visible = true
	transitioned_state.emit(self, "Flying_Jet_Right")
