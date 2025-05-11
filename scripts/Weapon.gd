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
var is_enemy: bool

func _ready():
    var parent: Node2D = get_parent()
    while not 'is_enemy' in parent:
        parent = parent.get_parent()
        if parent.name == 'Root': break
    is_enemy = parent.is_enemy

func _process(delta):
    if remaining_cooldown <= 0.0:
        fire()
    remaining_cooldown -= delta

func fire():
    var p = projectile.instantiate()
    p.weapon = self
    remaining_cooldown = cooldown
    Globals.projectile_manager.add_child(p)
    
    