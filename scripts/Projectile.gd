class_name Projectile

extends RigidBody2D

@export var flash_fade_time: float
@export var flash_random: bool
@export var fire_sample_bank_name: String
@export var hit_sample_bank_name: String
@export var explosion_scene: PackedScene
@export var hit_explosion_size: float

var weapon: Weapon
var light: PointLight2D
var remaining_lifetime: float
var remaining_flash: float
var damage: float
var last_linear_velocity: Vector2

func _ready():
	position = weapon.global_position + weapon.projectile_origin.rotated(weapon.global_rotation)
	linear_velocity = weapon.ship.linear_velocity + (Vector2.UP.rotated(weapon.global_rotation) * weapon.projectile_velocity)
	rotation = weapon.global_rotation
	remaining_lifetime = weapon.projectile_lifetime
	remaining_flash = flash_fade_time
	damage = weapon.projectile_damage

	var collision_mask_id = Globals.collision_layer_dict['Friendly'] if weapon.ship.is_enemy else Globals.collision_layer_dict['Enemy']
	collision_mask = (1 << 0) | (1 << collision_mask_id)

	light = get_node("PointLight2D")

	Globals.sample_manager.play_sample_at(fire_sample_bank_name, position, -12.0)

	body_entered.connect(hit)

func _physics_process(delta):
	last_linear_velocity = linear_velocity
	light.energy = max(remaining_flash / flash_fade_time, 0.0)
	remaining_flash -= delta

	if remaining_lifetime <= 0.0:
		queue_free()


func hit(object):
	Globals.sample_manager.play_sample_at(hit_sample_bank_name, position, -18.0)

	var explosion = explosion_scene.instantiate()
	explosion.size = hit_explosion_size
	explosion.linear_velocity = (object.linear_velocity + last_linear_velocity) * 0.5
	object.add_child(explosion)
	explosion.global_position = position
	object.take_damage(self)

	queue_free()
