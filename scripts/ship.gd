class_name Ship

extends RigidBody2D

@export var max_linear_velocity: Vector2 = Vector2(1000, 1000)
@export var max_angular_velocity: float = 2.0
@export var max_control_linear_velocity: float = 500.0
@export var max_control_angular_velocity: float = 90.0

var control_linear_velocity = Vector2.ZERO
var control_angular_velocity = 0.0
var thrust_vector: Vector2 = Vector2.ZERO

func _physics_process(_delta):
    if control_linear_velocity and linear_velocity.length() < max_linear_velocity.length():
        apply_force(control_linear_velocity)
        thrust_vector = control_linear_velocity
    else:
        thrust_vector = Vector2.ZERO

    if control_angular_velocity and abs(angular_velocity) < max_angular_velocity:
        apply_torque(control_angular_velocity)