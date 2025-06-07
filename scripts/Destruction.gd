class_name Destruction

extends Node2D

@export var shard_count: int = 10
@export var manual_rect: Rect2
@export var margin: float = 50
@export var time: float = 3.0

var shard_dicts = []
var time_remaining
var running = false

func _ready():
    var sprite = get_parent().get_node("Sprite2D")

    time_remaining = time

    var rect
    if manual_rect.size == Vector2.ZERO:
        rect = sprite.get_rect()
    else:
        rect = manual_rect

    var points = [
        rect.position,
        rect.position + Vector2(rect.size.x, 0),
        rect.position + Vector2(0, rect.size.y),
        rect.position + Vector2(rect.size.x, rect.size.y)
    ]

    for i in range(shard_count):
        var x = randf_range(rect.position.x + margin, rect.size.x - margin)
        var y = randf_range(rect.position.y + margin, rect.size.y - margin)
        var point = Vector2(x, y)
        points.append(point)

    var triangles = []
    var delaunay = Geometry2D.triangulate_delaunay(points)
    for i in range(0, delaunay.size(), 3):
        triangles.append([points[delaunay[i + 2]], points[delaunay[i + 1]], points[delaunay[i]]])

    var texture = sprite.texture
    for triangle in triangles:
        var centre = (triangle[0] + triangle[1] + triangle[2]) / 3.0
        var shard = Polygon2D.new()
        shard.texture = texture
        shard.texture_offset = (texture.get_size() * 0.5)
        shard.polygon = triangle

        var linear = centre.normalized() * (centre.length() * 0.5) * randf_range(0.5, 1.5)
        var angular = randf_range(-PI / 2.0, PI / 2.0)

        var shard_dict = {
            'shard': shard,
            'linear': linear,
            'angular': angular
        }
        shard_dicts.append(shard_dict)
        add_child(shard)

func _process(delta):
    if running:
        if time_remaining <= 0.0:
            queue_free()
        else:
            var bright = max((time_remaining - time / 2.0) / (time / 2.0), 0.0)
            var alpha = min(time_remaining / (time / 2.0), 1.0)
            for shard_dict in shard_dicts:
                var shard = shard_dict['shard']
                shard.position += shard_dict['linear'] * delta
                shard.rotation += shard_dict['angular'] * delta
                shard.modulate = Color(bright, bright, bright, alpha)

            time_remaining -= delta

func start():
    visible = true
    running = true