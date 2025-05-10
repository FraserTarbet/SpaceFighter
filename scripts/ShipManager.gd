extends Node

var ships = []
var friendly_ships = []
var enemy_ships = []

var show_collision_paths = true
var collision_path_time = 3.0

func _process(_delta):
	pass
	collision_avoidance()

func add_ship(ship):
	if not ships.has(ship):
		ships.append(ship)

	if ship.is_enemy:
		if not enemy_ships.has(ship):
			enemy_ships.append(ship)
	else:
		if not friendly_ships.has(ship):
			friendly_ships.append(ship)

func remove_ship(ship):
	for list in [ships, friendly_ships, enemy_ships]:
		if list.has(ship):
			list.remove(ship)

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



