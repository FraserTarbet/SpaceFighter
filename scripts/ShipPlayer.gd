extends Ship

var dead_zone_angle = PI / 24.0

signal player_death

func _ready():
    # Don't think this runs when script is added to an existing node.
	super()
	Globals.player_ship = self

func rotate_to_target(rotation_target: Vector2):
	var firing_offset = preferred_fire_vector.angle() + (PI / 2)
	var target_vector = (rotation_target - position).rotated(-firing_offset)
	var angle_to_target = Vector2.UP.rotated(rotation).angle_to(target_vector)
	# var move_vector = target_position - position

	if abs(angle_to_target) < dead_zone_angle: # or (rotation_target == target_position and move_vector.length() < dead_zone_position):
		control_angular_velocity = 0.0
	else:
		var time_to_target = abs(angle_to_target) / abs(angular_velocity)
		var time_to_stop = abs(angular_velocity) / max_angular_velocity
		if time_to_stop >= time_to_target:
			control_angular_velocity = max_control_angular_velocity if angle_to_target < 0.0 else -max_control_angular_velocity
		else:
			control_angular_velocity = -max_control_angular_velocity if angle_to_target < 0.0 else max_control_angular_velocity

func destroy():
	super()
	player_death.emit()
