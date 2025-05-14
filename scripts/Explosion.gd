class_name Explosion

extends Node2D

@export var size: float = 1.0

var particles: CPUParticles2D
var light: PointLight2D
var linear_velocity: Vector2
var remaining_lifetime: float

func _ready():
    particles = get_node("CPUParticles2D")
    light = get_node("PointLight2D")
    remaining_lifetime = size

    light.scale *= size
    particles.lifetime *= size
    particles.amount = int(particles.amount * size)
    particles.emission_sphere_radius *= size
    particles.initial_velocity_max *= size

    particles.emitting = true


func _process(delta):
    if remaining_lifetime <= 0.0:
        queue_free()
    else:
        global_position += linear_velocity * delta
        remaining_lifetime -= delta
        light.energy = remaining_lifetime