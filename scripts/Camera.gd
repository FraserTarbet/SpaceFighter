extends Camera2D

@export var follow_ship: Ship
var target_zoom = zoom
var min_zoom = Vector2(0.2, 0.2)
var max_zoom = Vector2(1.8, 1.8)

func _ready():
	Globals.camera = self

func _process(delta):
	if not is_instance_valid(follow_ship):
		if is_instance_valid(Globals.player_ship):
			follow_ship = Globals.player_ship
		else:
			get_random_follow_ship()
	var target = follow_ship.position
	position = lerp(position, target, 0.85 * delta)

	# Smooth zoom
	target_zoom = clamp(target_zoom, min_zoom, max_zoom)
	zoom = lerp(zoom, target_zoom, 0.95 * delta)

func get_random_follow_ship():
	var ships = ShipManager.ships
	var rand_i = randi_range(0, ships.size() - 1)
	follow_ship = ships[rand_i]
