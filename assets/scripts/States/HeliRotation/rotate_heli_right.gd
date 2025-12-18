extends State
class_name Rotate_Heli_Right

@onready var heli: CharacterBody2D = $"../.."
@onready var body: AnimatedSprite2D = $"../../Body"
@onready var tail_rotor: Sprite2D = $"../../Body/TailRotor"
@onready var nose_minigun: AnimatedSprite2D = $"../../Body/NoseMinigun"
@onready var rocket_pod: AnimatedSprite2D = $"../../Body/InnerPylon/RocketPod"
@onready var ir_missile: AnimatedSprite2D = $"../../Body/OuterPylon/IRMissile"


func enter_state():
	heli.is_rotating = true
	tail_rotor.visible = false
	nose_minigun.visible = false
	body.play()
	rocket_pod.play()
	ir_missile.play()
	await body.animation_finished
	heli.is_rotating = false
	tail_rotor.visible = true
	nose_minigun.visible = true
	transitioned_state.emit(self, "Flying_Right")
