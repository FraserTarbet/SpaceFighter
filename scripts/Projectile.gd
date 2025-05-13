class_name Projectile

extends RigidBody2D

@export var flash_fade_time: float
@export var flash_random: bool
@export var fire_sample_bank_name: String
@export var hit_sample_bank_name: String

var weapon: Weapon
var remaining_lifetime: float
var damage: float

func _ready():
	position = weapon.global_position + weapon.projectile_origin.rotated(weapon.global_rotation)
	linear_velocity = weapon.ship.linear_velocity + (Vector2.UP.rotated(weapon.global_rotation) * weapon.projectile_velocity)
	rotation = weapon.global_rotation
	remaining_lifetime = weapon.projectile_lifetime
	damage = weapon.projectile_damage

	var collision_mask_id = Globals.collision_layer_dict['Friendly'] if weapon.ship.is_enemy else Globals.collision_layer_dict['Enemy']
	collision_mask = (1 << 0) | (1 << collision_mask_id)

	Globals.sample_manager.play_sample_at(fire_sample_bank_name, position)

	body_entered.connect(hit)

func hit(object):
	Globals.sample_manager.play_sample_at(hit_sample_bank_name, position)