extends Node2D

var collision_lines = {}

func _ready():
    Globals.debug_objects = self

func add_collision_line(ship):
    var line = Line2D.new()
    line.points = PackedVector2Array([Vector2.ZERO, Vector2.ZERO])
    line.default_color = Color(0, 1, 0, 1)
    add_child(line)
    if not collision_lines.has(ship):
        collision_lines[ship] = []
    collision_lines[ship].append(line)