extends Camera2D

var target_zoom = zoom
var min_zoom = Vector2(0.2, 0.2)
var max_zoom = Vector2(1.8, 1.8)

func _ready():
    Globals.camera = self

func _process(delta):
    # Manually move camera to follow player rather than parenting
    var target = Globals.player_ship.position
    position = lerp(position, target, 0.75 * delta)

    # Smooth zoom
    target_zoom = clamp(target_zoom, min_zoom, max_zoom)
    zoom = lerp(zoom, target_zoom, 0.9 * delta)