extends Node

var debug_objects
var player_ship
var camera
var projectile_manager
var sample_manager

var collision_layer_dict = {
    'Environment' = 0,
    'Friendly' = 1,
    'Enemy' = 2,
    'Projectile' = 3
}