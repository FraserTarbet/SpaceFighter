extends Node

func _ready():
    var start_screen_scene: PackedScene = load("res://scenes/start.tscn")
    var start = start_screen_scene.instantiate()
    start.main = self
    add_child(start)

func initiate_menu():
    var start = get_node_or_null('Start')
    if start:
        start.queue_free()

    