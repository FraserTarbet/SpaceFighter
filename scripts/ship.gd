class_name Ship

extends RigidBody2D

@export var max_health: float = 1.0
@export var is_enemy: bool = false
@export var max_linear_velocity: Vector2 = Vector2(500, 500)
@export var max_angular_velocity: float = 3.0
@export var max_control_linear_velocity: float = 750.0
@export var max_control_angular_velocity: float = 15.0
@export var destroy_time: float = 1.0
@export var destroy_explosion: PackedScene
@export var linear_drag: float = 250.0
@export var angular_drag: float = 0.10

var health:float
var control_linear_velocity = Vector2.ZERO
var control_angular_velocity = 0.0
var thrust_vector: Vector2 = Vector2.ZERO
var is_destroying: bool = false
var integrator_linear: Vector2
var integrator_angular: float

var collision_points
var shield: Shield
var preferred_fire_vector: Vector2
var weapon_range: float

func _ready():
	ShipManager.add_ship(self)
	collision_points = get_node("CollisionPolygon2D").polygon
	shield = get_node("Shield")
	health = max_health
	if ShipManager.show_collision_paths:
		for i in collision_points.size() * 2:
			Globals.debug_objects.add_collision_line(self)
	if ShipManager.show_leading_positions and is_enemy:
		for child in Globals.player_ship.get_children():
			if child is WeaponSlot:
				Globals.debug_objects.add_leading_line(self, child.get_child(0))

	var weapon_slot_vectors = []
	for child in get_children():
		if child is WeaponSlot:
			weapon_slot_vectors.append(Vector2.UP.rotated(child.rotation))
			if not weapon_range:
				var weapon = child.get_child(0)
				weapon_range = weapon.projectile_velocity * weapon.projectile_lifetime
	if weapon_slot_vectors.size() == 0:
		preferred_fire_vector = Vector2.ZERO
	else:
		var vector_sum = Vector2.ZERO
		for vector in weapon_slot_vectors:
			vector_sum += vector
		preferred_fire_vector = (vector_sum / weapon_slot_vectors.size()).normalized()

func _physics_process(delta):
	if is_destroying:
		thrust_vector = Vector2.ZERO
		destroy_time -= delta
		var running_explosions = 0
		for c in get_children():
			if c is Explosion: running_explosions += 1
		if destroy_time <= 0.0:
			if not get_node("CollisionPolygon2D").disabled:
				get_node("CollisionPolygon2D").disabled = true
				Globals.set_all_canvas_items_alpha(self, 0.0)
			if running_explosions == 0:
				destroy()
	else:
		# Calc velocities for integrator
		if control_linear_velocity and linear_velocity.length() < max_linear_velocity.length():
			# apply_force(control_linear_velocity)
			integrator_linear = linear_velocity + (control_linear_velocity * delta)
			thrust_vector = control_linear_velocity
		else:
			integrator_linear = linear_velocity
			thrust_vector = Vector2.ZERO

		if control_angular_velocity and (abs(angular_velocity) < max_angular_velocity or (control_angular_velocity > 0) != (angular_velocity > 0)):
			# apply_torque(control_angular_velocity)
			integrator_angular = angular_velocity + (control_angular_velocity * delta)
		else:
			integrator_angular = angular_velocity
			
	# Apply drag to calculated forces
	var linear_magnitude = max(integrator_linear.length() - (linear_drag * delta), 0.0)
	integrator_linear = integrator_linear.normalized() * linear_magnitude

	var angular_magnitude: float = max(abs(integrator_angular) - angular_drag, 0.0)
	integrator_angular = angular_magnitude * (1.0 if integrator_angular >= 0.0 else -1.0)

func _integrate_forces(state):
	state.linear_velocity = integrator_linear
	state.angular_velocity = integrator_angular

	# Collisions
	for i in state.get_contact_count():
		if not state.get_contact_collider_object(i) is Ship: continue

		var relative_velocity = state.linear_velocity - state.get_contact_collider_velocity_at_position(i)
		var normal = state.get_contact_local_normal(i)

		if relative_velocity.dot(normal) > 0.0:
			continue
		else:
			var impulse_direction = normal.normalized()
			var impulse = impulse_direction * (relative_velocity.length()) * 1.5 # Look at this - use relative masses?
			state.apply_impulse(impulse, Vector2.ZERO)

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
	var remaining_projectile_damage = shield.hit(projectile)

	health -= remaining_projectile_damage
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
