extends Node2D

var touch_velocities = {}
var touch_positions = {}
var velocity_smoothing = 2
var rotation_smooting = 3
var min_detected_velocity = 100
var single_touch_proximity = 50
var angle_delta_to_torque = 5000
var rotation_node = null
var last_angle = null
var last_time = null
var last_zoom = null
var angular_velocity_samples = []
var max_linear_velocity
var max_angular_velocity

func _ready():
    await get_tree().process_frame
    max_linear_velocity = Globals.player_ship.max_control_linear_velocity
    max_angular_velocity = Globals.player_ship.max_control_angular_velocity

func _input(event):
    if event is InputEventScreenDrag or event is InputEventScreenTouch:
        touch(event)

func _process(_delta):

    # Ship movement
    var x = 0.0
    var y = 0.0
    var angular = 0.0

    if Input.is_action_pressed("move_left"):
        x = -max_linear_velocity
    elif Input.is_action_pressed("move_right"):
        x = max_linear_velocity

    if Input.is_action_pressed("move_up"):
        y = -max_linear_velocity
    elif Input.is_action_pressed("move_down"):
        y = max_linear_velocity

    if Input.is_action_pressed("rotate_anticlockwise"):
        angular = -max_angular_velocity
    elif Input.is_action_pressed("rotate_clockwise"):
        angular = max_angular_velocity

    Globals.player_ship.control_linear_velocity = Vector2(x, y)
    Globals.player_ship.control_angular_velocity = angular

    # Zoom
    if Input.is_action_pressed("zoom_in"):
        Globals.camera.target_zoom = Globals.camera.target_zoom * 1.05
    elif Input.is_action_pressed("zoom_out"):
        Globals.camera.target_zoom = Globals.camera.target_zoom * 0.95


func touch(event):
    if event is InputEventScreenTouch:
        if event.pressed and len(touch_velocities) < 2 and not touch_velocities.has(event.index):
            # Check if close proximity to existing touch index
            if touch_velocities == {} or (len(touch_velocities) == 1 and (touch_positions.values()[0] - event.position).length() > single_touch_proximity):
                touch_velocities[event.index] = []
                touch_positions[event.index] = event.position
        elif not event.pressed and touch_velocities.has(event.index):
            touch_velocities.erase(event.index)
            touch_positions.erase(event.index)
            angular_velocity_samples = []
            rotation_node = null
            last_angle = null
            last_time = null
            last_zoom = null
            Globals.player_ship.control_linear_velocity = null
            Globals.player_ship.control_angular_velocity = null

    if event is InputEventScreenDrag and touch_positions.has(event.index) and event.velocity.length() >= min_detected_velocity:
        touch_positions[event.index] = event.position
        if len(touch_velocities[event.index]) == velocity_smoothing:
            touch_velocities[event.index].remove_at(0)
        touch_velocities[event.index].append(event.velocity)

        var smooth_velocity = touch_velocities[event.index].reduce(func(accum, _nothing): return accum / len(touch_velocities[event.index]))
        if smooth_velocity.length() > max_linear_velocity:
            smooth_velocity = smooth_velocity.normalized() * max_linear_velocity
        Globals.player_ship.control_linear_velocity = smooth_velocity

        # Rotation
        if len(touch_positions) == 2:
            if rotation_node == null:
                rotation_node = Node2D.new()
            rotation_node.position = (touch_positions.values()[0] + touch_positions.values()[1]) / 2
            rotation_node.look_at(touch_positions.values()[1])

            if last_angle != null and (Time.get_ticks_msec()/1000.0 - last_time/1000.0) > 0.0:
                var angle_delta = wrapf(rotation_node.rotation - last_angle, -PI, PI)
                var angular_velocity = (angle_delta * angle_delta_to_torque) / (Time.get_ticks_msec()/1000.0 - last_time/1000.0)

                if len(angular_velocity_samples) > rotation_smooting:
                    angular_velocity_samples.remove_at(0)
                angular_velocity_samples.append(angular_velocity)

                var smooth_angular_velocity = angular_velocity_samples.reduce(func(accum, _nothing): return accum / len(angular_velocity_samples))
                Globals.player_ship.control_angular_velocity = clampf(smooth_angular_velocity, -max_angular_velocity, max_angular_velocity)

            last_angle = rotation_node.rotation
            last_time = Time.get_ticks_msec()
        else:
            rotation_node = null
            last_angle = null
            last_time = null

        # Zoom
        if len(touch_positions) == 2:
            var zoom = (touch_positions.values()[0] - touch_positions.values()[1]).length()
            if last_zoom != null:
                var delta = zoom / last_zoom
                Globals.camera.target_zoom = Globals.camera.target_zoom * delta
            last_zoom = zoom
        else:
            last_zoom = null