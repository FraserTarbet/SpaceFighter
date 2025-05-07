extends Camera2D

func _ready():
    Globals.camera = self

func _process(delta):
    # Manually move camera to follow player rather than parenting
    var target = Globals.player_ship.position
    position = lerp(position, target, 0.5 * delta)