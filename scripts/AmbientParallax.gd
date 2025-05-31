class_name AmbientParallax

extends Node2D

@export var texture: Texture2D
@export var area: int
@export var frequency: int
@export var scale_min: float
@export var scale_max: float
@export var opacity_min: float
@export var opacity_max: float
@export var min_depth: float
@export var max_depth: float

var rng = RandomNumberGenerator.new()
var last_camera_position = null

func _ready():
    for i in range(frequency):
        var node = Node2D.new()
        add_child(node)
        node.position = Vector2(rng.randi_range(-area, area), rng.randi_range(-area, area))

        var sprite = SpriteParallax.new()
        node.add_child(sprite)
        sprite.texture = texture
        var z = rng.randf_range(min_depth, max_depth)
        sprite.z = z
        sprite.z_index = int(sprite.z * 10)
        # sprite.rotation = PI * rng.randf()
        sprite.rotation_degrees = rng.randi_range(0, 359)
        sprite.modulate = Color(1, 1, 1, lerpf(opacity_max, opacity_min, z))
        sprite.scale = Vector2(1.0, 1.0) * lerpf(scale_min, scale_max, z)

func _process(_delta):
    if last_camera_position != null:
        var camera_position_delta = Globals.camera.position - last_camera_position
        for node in get_children():
            node.translate(-camera_position_delta)
            if node.position.length() > area:
                #node.translate(-node.position * 2)
                node.position = -node.position

    last_camera_position = Globals.camera.position

    