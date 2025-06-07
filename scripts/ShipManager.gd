extends Node

var ships = []
var friendly_ships = []
var enemy_ships = []

var ship_attackers = {} #{ship: [attacker, position]}

var show_collision_paths = false
var show_leading_positions = false
var collision_path_time = 0.5

var collision_detection_spread = 30
var next_collision_detection_frame = 1

var rng = RandomNumberGenerator.new()

func _process(_delta):
	collision_avoidance()

func add_ship(ship):
	if not ships.has(ship):
		ships.append(ship)
		ship_attackers[ship] = []

		ship.collision_detection_frame = next_collision_detection_frame
		next_collision_detection_frame = (next_collision_detection_frame + 1) % collision_detection_spread

	if ship.is_enemy:
		if not enemy_ships.has(ship):
			enemy_ships.append(ship)
	else:
		if not friendly_ships.has(ship):
			friendly_ships.append(ship)

func remove_ship(ship):
	for list in [ships, friendly_ships, enemy_ships]:
		if list.has(ship):
			list.erase(ship)

func collision_avoidance():
	var ship_paths = {}
	for ship in ships:
		var collision_paths = ship.get_collision_paths(collision_path_time)
		ship_paths[ship] = collision_paths

		if show_collision_paths:
			for i in ship.collision_points.size() * 2:
				Globals.debug_objects.collision_lines[ship][i].set_points(collision_paths[i])

	var colliding_ships = []
	for i in ship_paths.size():
		var current_ship = ship_paths.keys()[i]
		if Engine.get_process_frames() % current_ship.collision_detection_frame != 0:
			continue
		else:
			var current_paths = ship_paths[current_ship]
			for j in range(i + 1, ship_paths.size()):
				var other_ship = ship_paths.keys()[j]
				for current_path in current_paths:
					for other_path in ship_paths[other_ship]:
						if Geometry2D.segment_intersects_segment(current_path[0], current_path[1], other_path[0], other_path[1]):
							if not colliding_ships.has([current_ship, other_ship]):
								colliding_ships.append([current_ship, other_ship])

	# Lighter ship avoids?
	for collision in colliding_ships:
		var lighter_key = 0 if collision[0].mass < collision[1].mass else 1
		var heavier_key = abs(1 - lighter_key)
		if collision[lighter_key] is ShipAI:
			collision[lighter_key].avoid_collision(collision[heavier_key])

func get_nearest_target(caller_ship: Ship):
	var ship_list = friendly_ships if caller_ship.is_enemy else enemy_ships
	var caller_position = caller_ship.position

	var min_distance = null
	var min_ship = null
	for ship in ship_list:
		if ship.is_destroying:
			continue
		else:
			var distance = (ship.position - caller_position).length()
			if min_distance == null or distance < min_distance:
				min_distance = distance
				min_ship = ship

	return min_ship

func add_attack_tracking(ship: Ship, target: Ship):
	ship_attackers[target].append([ship, Vector2.ZERO])

func remove_attack_tracking(ship: Ship):
	var attacked_ship = null
	var to_remove = null
	for key in ship_attackers.keys():
		for attacker_position in ship_attackers[key]:
			if attacker_position[0] == ship:
				attacked_ship = key
				to_remove = attacker_position
				break
	if to_remove != null:
		ship_attackers[attacked_ship].erase(to_remove)

func set_attack_position(ship: Ship, target: Ship):
	var angle_to_attacker = target.get_angle_to(ship.position)
	var splits = [0, 2 * PI]
	var new_position
	for attacker_position in ship_attackers[target]:
		if attacker_position[1] != Vector2.ZERO:
			splits.append(attacker_position[1].angle())
	splits.sort()
	if splits.size() > 2:
		var split_segments = []
		var split_segment_sizes = []
		var split_segment_probabilities = []
		var total_probability = 0.0
		for i in range(len(splits) - 1):
			split_segments.append((splits[i] + splits[i + 1]) * 0.5)
			split_segment_sizes.append(splits[i + 1] - splits[i])
			var dot = Vector2.UP.rotated((splits[i] + splits[i + 1]) * 0.5).dot(Vector2.UP.rotated(angle_to_attacker))
			var probability = (splits[i + 1] - splits[i]) * (dot + 1.0)
			split_segment_probabilities.append(probability)
			total_probability += probability
		var random = rng.randf_range(0.0, total_probability)
		var selected_angle = split_segments[0]
		for i in split_segments.size():
			if split_segment_probabilities[i] <= random:
				break
			else:
				selected_angle = split_segments[i]
		new_position = Vector2.RIGHT.rotated(selected_angle) * (ship.weapon_range * rng.randf_range(0.5, 1.0))
	else:
		new_position = Vector2.RIGHT.rotated(rng.randf_range(0.0, 2 * PI)) * (ship.weapon_range * rng.randf_range(0.5, 1.0))

	for attacker_position in ship_attackers[target]:
		if attacker_position[0] == ship:
			attacker_position[1] = new_position
	 
func get_attack_position(ship: Ship, target: Ship):
	for attacker_position in ship_attackers[target]:
		if attacker_position[0] == ship:
			return target.position + attacker_position[1]

func get_ship_lead_position(ship: Ship, weapon: Weapon):
	var ship_lead_position: Vector2

	if weapon is ProjectileWeapon:
		var relative_position = ship.global_position - weapon.global_position
		var relative_velocity = ship.linear_velocity - weapon.ship.linear_velocity

		# a*t^2 + b*t + c = 0
		var a = relative_velocity.length_squared() - weapon.projectile_velocity ** 2
		var b = 2.0 * relative_position.dot(relative_velocity)
		var c = relative_position.length_squared()
		var discriminant = b * b - 4.0 * a * c

		if discriminant < 0.0:
			ship_lead_position = ship.global_position
		else:
			# Minimum positive time to intercept
			var sqrt_discriminant = sqrt(discriminant)
			var t1 = (-b - sqrt_discriminant) / (2.0 * a)
			var t2 = (-b + sqrt_discriminant) / (2.0 * a)

			if max(t1, t2) <= 0.0:
				ship_lead_position = ship.global_position
			else:
				var t: float
				if t1 > 0.0 and t2 > 0.0:
					t = min(t1, t2)
				elif t1 > 0.0:
					t = t1
				elif t2 > 0.0:
					t = t2

				ship_lead_position = ship.global_position + (relative_velocity * t)

			
		if show_leading_positions and weapon.ship == Globals.player_ship:
			var points: PackedVector2Array = [weapon.global_position, ship_lead_position]
			Globals.debug_objects.leading_markers[[ship, weapon]].set_points(points)
	else:
		ship_lead_position = ship.global_position

	return ship_lead_position

func get_ships_in_range(weapon: Weapon):
	var ship_list = friendly_ships if weapon.ship.is_enemy else enemy_ships
	var ships_in_range = []

	for ship in ship_list:
		var ship_lead_position = get_ship_lead_position(ship, weapon)
		var vector_to_ship_lead_position = ship_lead_position - weapon.global_position
		var required_rotation = Vector2.UP.rotated(weapon.weapon_slot.global_rotation).angle_to(vector_to_ship_lead_position)

		if abs(required_rotation) <= weapon.radius_radians and vector_to_ship_lead_position.length() <= weapon.weapon_range:
			ships_in_range.append(ship)

	return ships_in_range
