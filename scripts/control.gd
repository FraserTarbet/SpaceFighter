extends Node2D

var touch_velocities = {}
var touch_positions = {}
var velocity_smoothing = 2
var min_detected_velocity = 100
var single_touch_proximity = 50

func _input(event):
    if event is InputEventScreenTouch:
        if event.pressed and len(touch_velocities) < 2 and not touch_velocities.has(event.index):
            # Check if close proximity to existing touch index
            if touch_velocities == {} or (len(touch_velocities) == 1 and (touch_positions.values()[0] - event.position).length() > single_touch_proximity):
                touch_velocities[event.index] = []
                touch_positions[event.index] = event.position
        elif not event.pressed and touch_velocities.has(event.index):
            touch_velocities.erase(event.index)
            touch_positions.erase(event.index)
            Globals.player_ship.control_velocity = null

    if event is InputEventScreenDrag and touch_positions.has(event.index) and event.velocity.length() >= min_detected_velocity:
        touch_positions[event.index] = event.position
        if len(touch_velocities[event.index]) == velocity_smoothing:
            touch_velocities[event.index].remove_at(0)
        touch_velocities[event.index].append(event.velocity)

        var smooth_velocity = touch_velocities[event.index].reduce(func(accum, _nothing): return accum / len(touch_velocities[event.index]))

        Globals.player_ship.control_velocity = smooth_velocity

        print(event.velocity)