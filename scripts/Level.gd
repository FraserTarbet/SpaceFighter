extends Node2D

@export var is_menu_background: bool = false
@export var fade_in: float = 3.0
@export var fade_out: float = 2.0
@export var params: Dictionary

var fade_in_remaining: float
var fade_out_remaining: float
var fading_out: bool = false
var ships_parent
var ship_dict = {
	'condor': preload("res://scenes/ships/condor.tscn"),
	'kite': preload("res://scenes/ships/kite.tscn"),
	'buzzard': preload("res://scenes/ships/buzzard.tscn"),
	'sentinel': preload("res://scenes/ships/sentinel.tscn"),
	'arbalest': preload("res://scenes/ships/arbalest.tscn")
}

func _ready():
	ships_parent = get_node("Ships")
	fade_in_remaining = fade_in
	if fade_in > 0.0:
		modulate = Color(0, 0,0)
	fade_out_remaining = fade_out
	get_node("DirectionalLight2D").rotation = randf_range(0.0, 2 * PI)
	if is_menu_background:
		begin_menu_background()
	else:
		begin_level()

func _process(delta):
	if is_menu_background:
		process_menu_background()
	else:
		process_level()

	var fade: float = 1.0 - (fade_in_remaining / fade_in)
	modulate = Color(fade, fade, fade)

	fade_in_remaining = max(fade_in_remaining - delta, 0.0)

	if fading_out:
		fade = fade_out_remaining / fade_out
		modulate = Color(fade, fade, fade)
		if fade_out_remaining <= 0.0:
			end()
		else:
			fade_out_remaining -= delta

func spawn_player_ship(ship_type: String):
	var ship = ship_dict[ship_type].instantiate()

	# Need to reset properties when switching out the script - not the best approach...
	var property_dict = {}
	for property in ship.get_property_list():
		property_dict[property['name']] = ship.get(property['name'])
	ship.set_script(load("res://scripts/ShipPlayer.gd"))
	for property in ship.get_property_list():
		if property['name'] in property_dict.keys() and property['name'] != 'script':
			ship.set(property['name'], property_dict[property['name']])
	ships_parent.add_child(ship)
	Globals.player_ship = ship
	ship.player_death.connect(game_over)

func spawn_AI_ship(ship_type: String):
	var ship = ship_dict[ship_type].instantiate()
	ship.rotate(randf_range(0.0, PI * 2))
	ships_parent.add_child(ship)

	var vector = Vector2.UP.rotated(randf_range(0.0, PI * 2)) * randf_range(4000, 5000)
	ship.position = Globals.camera.position + vector

	return ship
	# Check placement

func begin_menu_background():
	if Globals.is_low_spec:
		spawn_AI_ship('condor')		
	else:
		for i in range(3):
			var r = randf()
			if r > 0.8:
				spawn_AI_ship('condor')
			elif r > 0.4:
				spawn_AI_ship('kite')
			else:
				spawn_AI_ship('buzzard')
	
	Globals.camera.get_random_follow_ship()

func process_menu_background():
	if Globals.is_low_spec:
		if ShipManager.enemy_ships.size() < 3:
			var r  = randf()
			if r >= 0.7:
				spawn_AI_ship('arbalest')
			else:
				spawn_AI_ship('sentinel')
		if ShipManager.friendly_ships.size() < 2:
			var r = randf()
			if r > 0.8:
				spawn_AI_ship('condor')
			elif r > 0.4:
				spawn_AI_ship('kite')
			else:
				spawn_AI_ship('buzzard')
	else:
		if ShipManager.enemy_ships.size() <= 4:
			var r  = randf()
			if r >= 0.7:
				spawn_AI_ship('arbalest')
			else:
				spawn_AI_ship('sentinel')
		if ShipManager.friendly_ships.size() <= 2:
			var r = randf()
			if r > 0.8:
				spawn_AI_ship('condor')
			elif r > 0.4:
				spawn_AI_ship('kite')
			else:
				spawn_AI_ship('buzzard')

func start_fade_out():
	fading_out = true

func end():
	ShipManager.clear()
	for ship in ships_parent.get_children():
		if ship is ShipAI:
			ship.reset_state()
	queue_free()
	Globals.main.receive_close_complete()

func game_over():
	ShipManager.clear()
	for ship in ships_parent.get_children():
		if ship is ShipAI:
			ship.reset_state()
	queue_free()
	Globals.main.initiate_start()

func begin_level():
	if 'player_ship' in params:
		add_child(PlayerControl.new())
		spawn_player_ship(params['player_ship'])

func process_level():
	if ShipManager.enemy_ships.size() < 2:
		var r = randf()
		if r > 0.6:
			spawn_AI_ship('arbalest')
		else:
			spawn_AI_ship('sentinel')