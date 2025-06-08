extends Node2D

@export var is_menu_background: bool = false
@export var fade_in: float = 3.0

var fade_in_remaining: float
var ships_parent
var ship_dict = {
	'mothership': preload("res://scenes/ships/mothership.tscn"),
	'kite': preload("res://scenes/ships/kite.tscn"),
	'buzzard': preload("res://scenes/ships/buzzard.tscn"),
	'sentinel': preload("res://scenes/ships/sentinel.tscn"),
	'arbalest': preload("res://scenes/ships/arbalest.tscn")
}

func _ready():
	ships_parent = get_node("Ships")
	fade_in_remaining = fade_in
	get_node("DirectionalLight2D").rotation = randf_range(0.0, 2 * PI)
	if is_menu_background:
		begin_menu_background()
	else:
		pass

func _process(delta):
	if is_menu_background:
		process_menu_background()
	else:
		pass

	var fade: float = 1.0 - (fade_in_remaining / fade_in)
	modulate = Color(fade, fade, fade)

	fade_in_remaining = max(fade_in_remaining - delta, 0.0)

func spawn_ship(ship_type: String, is_enemy: bool):
	var ship = ship_dict[ship_type].instantiate()
	ship.rotate(randf_range(0.0, PI * 2))
	ships_parent.add_child(ship)

	var vector = Vector2.UP.rotated(randf_range(0.0, PI * 2)) * randf_range(4000, 5000)
	ship.position = Globals.camera.position + vector

	return ship

	# Check placement

func begin_menu_background():
	if Globals.is_low_spec:
		spawn_ship('mothership', false)		
	else:
		for i in range(3):
			var r = randf()
			if r > 0.8:
				spawn_ship('mothership', false)
			elif r > 0.4:
				spawn_ship('kite', false)
			else:
				spawn_ship('buzzard', false)
	
	Globals.camera.get_random_follow_ship()

func process_menu_background():
	if Globals.is_low_spec:
		if ShipManager.enemy_ships.size() < 3:
			var r  = randf()
			if r >= 0.7:
				spawn_ship('arbalest', true)
			else:
				spawn_ship('sentinel', true)
		if ShipManager.friendly_ships.size() < 2:
			var r = randf()
			if r > 0.8:
				spawn_ship('mothership', false)
			elif r > 0.4:
				spawn_ship('kite', false)
			else:
				spawn_ship('buzzard', false)
	else:
		if ShipManager.enemy_ships.size() <= 4:
			var r  = randf()
			if r >= 0.7:
				spawn_ship('arbalest', true)
			else:
				spawn_ship('sentinel', true)
		if ShipManager.friendly_ships.size() <= 2:
			var r = randf()
			if r > 0.8:
				spawn_ship('mothership', false)
			elif r > 0.4:
				spawn_ship('kite', false)
			else:
				spawn_ship('buzzard', false)