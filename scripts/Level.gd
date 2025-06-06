extends Node2D

@export var is_menu_background: bool = false

var ships_parent
var ship_dict = {
	'mothership': preload("res://scenes/ships/mothership.tscn"),
	'kite': preload("res://scenes/ships/kite.tscn"),
	'buzzard': preload("res://scenes/ships/buzzard.tscn"),
	'enemy_ship': preload("res://scenes/ships/enemy_ship.tscn")
}

func _ready():
	ships_parent = get_node("Ships")

	# spawn_ship('mothership', false)
	# Globals.camera.get_random_follow_ship()

	get_node("DirectionalLight2D").rotation = randf_range(0.0, 2 * PI)

	begin_menu_background()

func _process(_delta):
	if ShipManager.enemy_ships.size() <= 4:
		spawn_ship('enemy_ship', true)
	if ShipManager.friendly_ships.size() <= 2:
		var r = randf()
		if r > 0.8:
			spawn_ship('mothership', false)
		elif r > 0.4:
			spawn_ship('kite', false)
		else:
			spawn_ship('buzzard', false)

func spawn_ship(ship_type: String, is_enemy: bool):
	var ship = ship_dict[ship_type].instantiate()
	ship.rotate(randf_range(0.0, PI * 2))
	ships_parent.add_child(ship)

	var vector = Vector2.UP.rotated(randf_range(0.0, PI * 2)) * randf_range(4000, 5000)
	ship.position = Globals.camera.position + vector

	return ship

	# Check placement

func begin_menu_background():
	for i in range(3):
		var r = randf()
		if r > 0.9:
			spawn_ship('mothership', false)
		elif r > 0.4:
			spawn_ship('kite', false)
		else:
			spawn_ship('buzzard', false)
	for i in range(5):
		spawn_ship('mothership', true)
	
	Globals.camera.get_random_follow_ship()

func process_menu_background():
	if ShipManager.enemy_ships.size() <= 4:
		spawn_ship('enemy_ship', true)
	if ShipManager.friendly_ships.size() <= 2:
		var r = randf()
		if r > 0.8:
			spawn_ship('mothership', false)
		elif r > 0.4:
			spawn_ship('kite', false)
		else:
			spawn_ship('buzzard', false)