extends Node

var music_player: AudioStreamPlayer
var start_screen_scene: PackedScene = load("res://scenes/start.tscn")
var level_scene: PackedScene = load("res://scenes/level.tscn")
var menu_scene: PackedScene = load("res://scenes/menu.tscn")

var music_streams = {
    'A': ResourceLoader.load("res://music/SpaceFighter_A.mp3")
}

func _ready():
    music_player = get_node("MusicPlayer")
    
    var start = start_screen_scene.instantiate()
    start.main = self
    add_child(start)

func initiate_menu():
    var start = get_node_or_null('Start')
    if start:
        start.queue_free()

    var level = level_scene.instantiate()
    level.is_menu_background = true
    add_child(level)

    var stream = music_streams['A']
    music_player.stream = stream
    music_player.play()

    var menu = menu_scene.instantiate()
    add_child(menu)



    