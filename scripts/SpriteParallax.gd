class_name SpriteParallax

extends Sprite2D

@export var z: float = 0.0 # Positive numbers closer to viewer
var parent: Node2D

func _ready():
    parent = get_parent()

func _process(_delta):
    position = (parent.global_position - Globals.camera.global_position) * z