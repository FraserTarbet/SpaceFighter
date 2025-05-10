class_name ShipAI

extends Ship

@export var target_position: Vector2
@export var target_ship: Ship

@export var avoidance_timer: float = 3.0

var rotation_target: Vector2
var dead_zone_position = 100.0
var dead_zone_angle = 0.25

var state: String
var state_timer: float = 0.0
var avoided_ships = []

var rng = RandomNumberGenerator.new()

# Use manager to scatter enemies around player targets? Give them a target position, move them around intermittently?

# Movement functions:
    # Collision avoidance - use a manager to detect objects (including player) that are on a collision course and divert
    # Position around target - intermittently choose a position in 180deg range of target. Allow to drift. Use a manager?
    # Move towards target - move from far away
    # Passively follow the movement of the target - e.g. if player rotates, rotate around to dodge return fire

# Simple behaviour, no self-preservation besides collision avoidance
# Some ships might seek collisions?

func _process(delta):

    rotation_target = target_position if not target_ship else target_ship.position

    if target_position:
        move_to_target_position()

    if rotation_target != null:
        rotate_to_target()

    state_timer = max(state_timer -delta, 0.0)
    if state_timer == 0.0 and state != 'default':
        reset_state()

func move_to_target_position():
    var move_vector = target_position - position
    var desired_linear_velocity = move_vector.normalized() * max_linear_velocity

    if move_vector.length() < dead_zone_position and linear_velocity.length() < dead_zone_position:
        control_linear_velocity = Vector2.ZERO
    else:
        if linear_velocity.dot(move_vector) > 0.0 and get_stopping_distance() > move_vector.length():
            control_linear_velocity = -desired_linear_velocity
        else:
            control_linear_velocity = desired_linear_velocity

func rotate_to_target():
    var target_vector = rotation_target - position
    var angle_to_target = (target_vector.angle() + deg_to_rad(90)) - rotation
    var move_vector = target_position - position

    if abs(angle_to_target) < dead_zone_angle or (rotation_target == target_position and move_vector.length() < dead_zone_position):
        control_angular_velocity = 0.0
    else:
        var time_to_target = abs(angle_to_target) / abs(angular_velocity)
        var time_to_stop = abs(angular_velocity) / max_angular_velocity
        if time_to_stop >= time_to_target:
            control_angular_velocity = max_control_angular_velocity if angle_to_target < 0.0 else -max_control_angular_velocity
        else:
            control_angular_velocity = -max_control_angular_velocity if angle_to_target < 0.0 else max_control_angular_velocity

func avoid_collision(other_ship: Ship):
    if not avoided_ships.has(other_ship):
        avoided_ships.append(other_ship)
        state = 'avoid_collision'
        state_timer = avoidance_timer

        var avoid_vectors = []
        for ship in avoided_ships:
            var vector_away = (position - ship.position)
            var opposite_velocity = -(other_ship.linear_velocity)
            avoid_vectors.append(vector_away + opposite_velocity.normalized())

        var average_vector = Vector2.ZERO
        for v in avoid_vectors:
            average_vector = average_vector + v
        average_vector = average_vector.normalized() * rng.randf_range(250, 750)

        target_position = position + average_vector

func reset_state():
    state = 'default'
    avoided_ships.clear()