extends Node2D

var collision_lines = {}
var leading_markers = {}

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

func add_leading_line(ship, player_weapon):
    # var marker = Marker2D.new()
    # marker.position = ship.position
    # add_child(marker)
    # leading_markers[[ship, player_weapon]] = marker

    var line = Line2D.new()
    line.points = PackedVector2Array([Vector2.ZERO, Vector2.ZERO])
    line.default_color = Color(1, 0, 0, 1)
    line.width = 5.0
    add_child(line)
    leading_markers[[ship, player_weapon]] = line
