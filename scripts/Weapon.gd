class_name Weapon

extends Node2D

@export var projectile: PackedScene
@export var projectile_origin: Vector2
@export var projectile_velocity: float
@export var projectile_lifetime: float
@export var projectile_burst_amount: int
@export var projectile_burst_spread: int
@export var projectile_damage: float
@export var radius: float
@export var cooldown: float

var is_firing: bool = true
var remaining_cooldown: float = 0.0
var ship: Ship
var weapon_slot: WeaponSlot
var projectile_range: float
var radius_radians: float

func _ready():
	var parent: Node2D = get_parent()
	while not parent is Ship:
		if parent is WeaponSlot: weapon_slot = parent
		parent = parent.get_parent()
		if parent.name == 'Root': break
	ship = parent

	projectile_range = projectile_velocity * projectile_lifetime
	radius_radians = deg_to_rad(radius)

func _process(delta):
	aim()
	if remaining_cooldown <= 0.0 and is_firing:
		fire()
	remaining_cooldown = max(remaining_cooldown - delta, 0.0)

func aim():
	var ships_in_range = ShipManager.get_ships_in_range(self)

	if ships_in_range.size() > 0:
		var closest_ship = null
		var min_distance = null
		for target_ship in ships_in_range:
			var ship_lead_position = ShipManager.get_ship_lead_position(target_ship, self)
			var distance = (ship_lead_position - global_position).length()
			if min_distance == null or distance < min_distance:
				closest_ship = target_ship
				min_distance = distance

		var points_in_radius = [Vector2.ZERO]
		var rotation_sum = Vector2.UP.rotated(weapon_slot.global_rotation).angle_to(ShipManager.get_ship_lead_position(closest_ship, self) - global_position)
		for point in closest_ship.collision_points:
			var global_point = closest_ship.global_position + point.rotated(closest_ship.global_rotation)
			var vector_to_point = (global_point - global_position)
			var required_rotation = Vector2.UP.rotated(weapon_slot.global_rotation).angle_to(vector_to_point)
			if abs(required_rotation) <= radius_radians:
				points_in_radius.append(point)
				rotation_sum += required_rotation

		var average_rotation = rotation_sum / points_in_radius.size()
		rotation = average_rotation
		is_firing = true

	else:
		rotation = 0.0
		is_firing = false

func fire():
	var p = projectile.instantiate()
	p.weapon = self
	remaining_cooldown = cooldown
	Globals.projectile_manager.add_child(p)
	
	
