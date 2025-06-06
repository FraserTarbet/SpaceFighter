class_name ProjectileWeapon

extends Weapon

@export var projectile: PackedScene
@export var projectile_origin: Vector2
@export var projectile_velocity: float
@export var projectile_lifetime: float
@export var projectile_burst_amount: int
@export var projectile_burst_spread: int
@export var projectile_damage: float

var projectile_range: float

func _ready():
	super()
	projectile_range = projectile_velocity * projectile_lifetime

func _process(delta):
	if ship.is_destroying:
		return
	else:
		aim()
		if remaining_cooldown <= 0.0 and is_firing:
			fire()
		remaining_cooldown = max(remaining_cooldown - delta, 0.0)

func fire():
	var p = projectile.instantiate()
	p.weapon = self
	remaining_cooldown = cooldown
	Globals.projectile_manager.add_child(p)
