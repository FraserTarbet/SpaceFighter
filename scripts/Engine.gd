class_name EngineParticles

extends CPUParticles2D


@export var max_thrust: float = 500

var emit_strength: float = 0.0



@export var thrust_vector: Vector2
@export var cooldown_max: float = 0.5
var cooldown: float = 0.0
var ship: Ship
var sound: AudioStreamPlayer2D
var max_volume

func _ready():
	ship = get_parent()
	sound = get_node_or_null("AudioStreamPlayer2D")
	if sound != null:
		max_volume = sound.volume_db

func _process(delta):
	var rotated_ship_vector = ship.thrust_vector.rotated(-ship.get_global_rotation())
	var thrust_direction = thrust_vector.dot(rotated_ship_vector)

	if thrust_direction > 0.0:
		emitting = true
		cooldown = min(cooldown + delta, cooldown_max)
	else:
		if cooldown == 0.0:
			emitting = false
		cooldown = max(cooldown - delta, 0.0)

	if sound != null:
		sound.volume_db = -60.0 + (max_volume - -60.0) * (cooldown / cooldown_max)