extends Node

var debug_objects
var player_ship
var camera
var projectile_manager
var sample_manager
var hud

var is_low_spec

var collision_layer_dict = {
	'Environment' = 0,
	'Friendly' = 1,
	'Enemy' = 2,
	'Projectile' = 3
}

func _ready():
	is_low_spec = OS.has_feature("web")

func set_all_canvas_items_alpha(node: Node2D, alpha: float, exclude_destruction = true):
	for child in node.get_children():
		if child is CanvasItem:
			if exclude_destruction and (child is Destruction or child is Explosion):
				continue
			child.modulate = Color(1, 1, 1, alpha)
		set_all_canvas_items_alpha(child, alpha)
