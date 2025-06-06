class_name Beam

extends Line2D

@export var fade: float
var remaining_fade: float
var starting_width: float
var light: PointLight2D

func _ready():
    remaining_fade = fade
    starting_width = width
    light = get_node("PointLight2D")
    light.global_position = points[0]
    # Sound
    # Light?

func _process(delta):
    if remaining_fade <= 0.0:
        queue_free()
    else:
        modulate = Color(1, 1, 1, remaining_fade / fade)
        width = starting_width * (remaining_fade / fade)
        light.energy = remaining_fade / fade
        remaining_fade -= delta