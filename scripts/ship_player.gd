extends Ship

var control_velocity = null

func _ready():
    Globals.player_ship = self

func _physics_process(_delta):
    if control_velocity != null:
        apply_force(control_velocity)