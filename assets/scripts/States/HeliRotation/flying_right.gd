extends State
class_name Flying_Right

@onready var heli: CharacterBody2D = $"../.."
@onready var body: AnimatedSprite2D = $"../../Body"
@onready var tail_rotor: Sprite2D = $"../../Body/TailRotor"
@onready var nose_minigun: AnimatedSprite2D = $"../../Body/NoseMinigun"
#@onready var hardpoint_1: Marker2D = $"../../Body/InnerPylon"
#@onready var hardpoint_2: Marker2D = $"../../Body/OuterPylon"
@onready var hitbox: CollisionPolygon2D = $"../../Hitbox"
@onready var skids: CollisionShape2D = $"../../Skids"
@onready var rotate_timer: Timer = $"../../RotateTimer"

func enter_state():
	heli.flying_left = false
	heli.is_rotating = false
	tail_rotor.z_index = -1
	tail_rotor.position.x = -1285.0
	tail_rotor.offset.x = -5.0
	tail_rotor.flip_h = true
	nose_minigun.position.x = 380.0
	nose_minigun.flip_v = false
	#hardpoint_1.position.x = -211.0
	#hardpoint_2.position.x = -211.0
	hitbox.scale.x = -1.0
	hitbox.position.x = -14.0
	skids.position.x = 411.5

func Update(_delta: float):
	if heli.velocity.x < -2000:
		if rotate_timer.is_stopped():
			rotate_timer.start()
	else:
		if not rotate_timer.is_stopped():
			rotate_timer.stop()

func _on_rotate_timer_timeout() -> void:
	transitioned_state.emit(self, "Rotate_Heli_Left")
