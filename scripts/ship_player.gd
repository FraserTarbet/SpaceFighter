extends Ship

var control_linear_velocity = null
var control_angular_velocity = null

func _ready():
    Globals.player_ship = self

func _physics_process(_delta):
    if control_linear_velocity != null:
        apply_force(control_linear_velocity)
    if control_angular_velocity != null:
        apply_torque(control_angular_velocity)