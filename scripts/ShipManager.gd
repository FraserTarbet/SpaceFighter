extends Node

var ships = []
var friendly_ships = []
var enemy_ships = []

var ship_attackers = {} #{ship: [attacker, position]}

var show_collision_paths = false
var collision_path_time = 0.5

var rng = RandomNumberGenerator.new()

func _process(_delta):
	collision_avoidance()

func add_ship(ship):
	if not ships.has(ship):
		ships.append(ship)
		ship_attackers[ship] = []

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
		collision[lighter_key].avoid_collision(collision[heavier_key])

func get_nearest_target(caller_ship: Ship):
	var ship_list = friendly_ships if caller_ship.is_enemy else enemy_ships
	var caller_position = caller_ship.position

	var min_distance = null
	var min_ship = null
	for ship in ship_list:
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
