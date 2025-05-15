class_name Ship

extends RigidBody2D

@export var health: float = 1.0
@export var is_enemy: bool = false
@export var max_linear_velocity: Vector2 = Vector2(1000, 1000)
@export var max_angular_velocity: float = 2.0
@export var max_control_linear_velocity: float = 500.0
@export var max_control_angular_velocity: float = 90.0
@export var destroy_time: float = 1.0
@export var destroy_explosion: PackedScene

var control_linear_velocity = Vector2.ZERO
var control_angular_velocity = 0.0
var thrust_vector: Vector2 = Vector2.ZERO
var is_destroying: bool = false

var collision_points
var weapon_range = 500.0 # Get this from weapons



func _ready():
	ShipManager.add_ship(self)
	collision_points = get_node("CollisionPolygon2D").polygon
	if ShipManager.show_collision_paths:
		for i in collision_points.size() * 2:
			Globals.debug_objects.add_collision_line(self)


func _physics_process(delta):
	if is_destroying:
		thrust_vector = Vector2.ZERO
		destroy_time -= delta
		var running_explosions = 0
		for c in get_children():
			if c is Explosion: running_explosions += 1
		if destroy_time <= 0.0:
			get_node("Sprite2D").modulate = Color(1, 1, 1, 0)
			get_node("CollisionPolygon2D").disabled = true
			if running_explosions == 0:
				destroy()
				print("tyui")
	else:
		if control_linear_velocity and linear_velocity.length() < max_linear_velocity.length():
			apply_force(control_linear_velocity)
			thrust_vector = control_linear_velocity
		else:
			thrust_vector = Vector2.ZERO

		if control_angular_velocity and abs(angular_velocity) < max_angular_velocity:
			apply_torque(control_angular_velocity)

func get_stopping_distance():
	if linear_velocity.length() <= 0.0:
		return 0.0
	else:
		var t_stop = (mass / linear_damp) * log(1.0 + (linear_damp * linear_velocity.length()) / max_control_linear_velocity)
		var x_stop = (mass / linear_damp) * linear_velocity.length() - (max_control_linear_velocity / linear_damp) * t_stop
		return x_stop

func get_collision_paths(time):
	var paths = []
	for i in collision_points.size():
		var start_point = position + collision_points[i].rotated(rotation)
		var end_point = start_point + linear_velocity * time
		paths.append([start_point, end_point])

		# Shape
		var next_i = (i + 1) % collision_points.size()
		paths.append([start_point, position + collision_points[next_i].rotated(rotation)])

	return paths

func take_damage(projectile: Projectile):
	health -= projectile.weapon.projectile_damage
	if health <= 0.0 and not is_destroying:
		is_destroying = true

		var spread = (collision_points[int(collision_points.size() * 0.5)] - collision_points[0]).length()
		var pre_delay = randf_range(0.0, 1.0)
		while pre_delay < destroy_time:
			var explosion = destroy_explosion.instantiate()
			explosion.size = randf_range(destroy_time * 0.2, destroy_time * 0.8)
			explosion.pre_delay = pre_delay
			add_child(explosion)
			explosion.position += Vector2.UP.rotated(randf_range(0, 2 * PI)) * randf_range(0.2 * spread, spread)
			pre_delay += randf_range(0.0, 1.0)
		var final_explosion = destroy_explosion.instantiate()
		final_explosion.size = destroy_time * 2.0
		final_explosion.pre_delay = destroy_time
		add_child(final_explosion)

func destroy():
	ShipManager.remove_ship(self)
	queue_free()