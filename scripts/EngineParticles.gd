class_name EngineParticles

extends CPUParticles2D

@export var thrust_vector: Vector2
@export var max_thrust: float = 500
var ship: Ship
var emit_strength: float = 0.0

func _ready():
	ship = get_parent()

func _process(delta):
	var rotated_ship_vector = ship.thrust_vector.rotated(-ship.get_global_rotation())
	var new_strength = thrust_vector.dot(rotated_ship_vector) * clampf((rotated_ship_vector.length() / max_thrust), 0.0, max_thrust)
	emit_strength = lerpf(emit_strength, new_strength, 0.5 * delta)
	
	if emitting and emit_strength < 0.2:
		emitting = false
	elif not emitting and emit_strength >= 0.2:
		emitting = true
