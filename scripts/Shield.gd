class_name Shield

extends Polygon2D

@export var max_energy: float
@export var recharge_delay: float
@export var recharge_speed: float
@export var flare_time: float
@export var flare_warmup: float
@export var gradient: Gradient

var energy: float
var remaining_recharge_delay: float = 0.0
var flare_vector_start: Vector2
var flare_vector_end: Vector2
var remaining_flare_time: float = 0.0

func _ready():
    energy = max_energy

func _process(delta):
    # Flare
    if remaining_flare_time > 0.0 and energy > 0.0:
        var base_intensity: float
        if remaining_flare_time > flare_time - flare_warmup:
            base_intensity = (flare_time - remaining_flare_time) / flare_warmup
        else:
            base_intensity = remaining_flare_time / (flare_time - flare_warmup)

        var flare_vector = lerp(flare_vector_end, flare_vector_start, remaining_flare_time / flare_time)
        var distances = []
        var min_distance = null
        for v in polygon:
            var distance = (v - flare_vector).length()
            distances.append(distance)
            if min_distance == null or distance < min_distance:
                min_distance = distance

        var colors = vertex_colors
        for i in range(polygon.size()):
            var a = (min_distance / distances[i]) * base_intensity
            var c = gradient.sample(energy / max_energy)
            c.a = a
            colors[i] = c
        vertex_colors = colors

        remaining_flare_time -= delta
    else:
        var colors = vertex_colors
        for i in range(polygon.size()):
            colors[i].a = 0.0
        vertex_colors = colors

    # Recharge
    if remaining_recharge_delay > 0.0:
        remaining_recharge_delay -= delta
    elif energy < max_energy:
        energy = min(energy + (recharge_speed * delta), max_energy)

func hit(projectile: Projectile):
    var projectile_local_position = (projectile.global_position - global_position).rotated(-global_rotation)
    flare_vector_start = projectile_local_position
    flare_vector_end = -projectile_local_position
    remaining_flare_time = flare_time

    var remaining_projectile_damage = max(projectile.weapon.projectile_damage - energy, 0.0)
    energy = max(energy - projectile.weapon.projectile_damage, 0.0)
    remaining_recharge_delay = recharge_delay

    return remaining_projectile_damage