extends State
class_name Flying_Jet_Left

@onready var jet: CharacterBody2D = $"../.."
@onready var body: AnimatedSprite2D = $"../../Body"
@onready var cannon: Marker2D = $"../../Body/Cannon"
@onready var elevator: Sprite2D = $"../../Body/Elevator"
@onready var weapon_bay: Marker2D = $"../../Body/WeaponBay"
@onready var hitbox: CollisionPolygon2D = $"../../Hitbox"
@onready var gear: CollisionShape2D = $"../../Gear"
@onready var flying_jet_left: Node = $"."
@onready var body_rotate_timer: Timer = $"../../BodyRotateTimer"

func enter_state():
	jet.flying_left = true
	jet.is_rotating = false
	cannon.position.y = 110.0
	elevator.flip_v = false
	elevator.position.y = 150.0
	weapon_bay.position.y = 268.0
	weapon_bay.rotation_degrees = 0.0
	hitbox.scale.y = 1.0
	hitbox.position.y = 0.0
	gear.position.y = 415.0

func Update(_delta: float):
	if abs(jet.global_rotation_degrees) > 90.0:
		if body_rotate_timer.is_stopped():
			body_rotate_timer.start()
	else:
		if not body_rotate_timer.is_stopped():
			body_rotate_timer.stop()

func _on_body_rotate_timer_timeout() -> void:
	transitioned_state.emit(self, "Flip_Mirrored")
