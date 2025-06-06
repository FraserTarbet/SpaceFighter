class_name BeamWeapon

extends Weapon

@export var beam: PackedScene
@export var beam_origin: Vector2
@export var beam_range: float
@export var beam_damage: float
var ray_cast: RayCast2D

func _ready():
	super()
	weapon_range = beam_range
	ray_cast = get_node("RayCast2D")
	var collision_mask_id = Globals.collision_layer_dict['Friendly'] if ship.is_enemy else Globals.collision_layer_dict['Enemy']
	ray_cast.collision_mask = (1 << 0) | (1 << collision_mask_id)
	ray_cast.position = beam_origin
	ray_cast.target_position = Vector2.UP * beam_range

func _process(delta):
	if ship.is_destroying:
		return
	else:
		aim()
		if remaining_cooldown <= 0.0 and is_firing:
			fire()
		remaining_cooldown = max(remaining_cooldown - delta, 0.0)

func fire():
	var beam_end: Vector2

	if ray_cast.is_colliding():
		beam_end = ray_cast.get_collision_point()
		var collider = ray_cast.get_collider()
		if collider is Ship:
			collider.take_damage(beam_damage, beam_end)
	else:
		beam_end = ray_cast.global_position + ray_cast.target_position.rotated(ray_cast.global_rotation)

	var fired_beam = beam.instantiate()
	fired_beam.points = PackedVector2Array([to_global(ray_cast.position), beam_end])
	Globals.projectile_manager.add_child(fired_beam)

	remaining_cooldown = cooldown

