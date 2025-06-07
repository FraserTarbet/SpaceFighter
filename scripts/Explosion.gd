class_name Explosion

extends Node2D

@export var size: float = 1.0
@export var sample_bank_name: String

var particles: CPUParticles2D
var light: PointLight2D
var linear_velocity: Vector2
var remaining_lifetime: float
var pre_delay: float = 0.0

func _ready():
    particles = get_node("CPUParticles2D")
    light = get_node("PointLight2D")
    remaining_lifetime = size

    light.scale *= size
    particles.lifetime = particles.lifetime * (size * 0.5)
    particles.amount = int(float(particles.amount) * size)
    particles.emission_sphere_radius *= size
    particles.initial_velocity_max *= size

func _process(delta):
    global_position += linear_velocity * delta
    pre_delay -= delta

    if pre_delay <= 0.0 and not light.visible:
        start()

    if pre_delay <= 0.0 and light.visible:    
        remaining_lifetime -= delta
        light.scale = Vector2(1, 1) * (remaining_lifetime / size)

    if remaining_lifetime <= 0.0:
        queue_free()

func start():
    light.visible = true
    particles.emitting = true
    Globals.sample_manager.play_sample_at(sample_bank_name, global_position, -3.0 - (2.0 - size))
