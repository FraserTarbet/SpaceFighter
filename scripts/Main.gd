extends Node

var music_player: AudioStreamPlayer
var start_screen_scene: PackedScene = load("res://scenes/start.tscn")
var level_scene: PackedScene = load("res://scenes/level.tscn")
var menu_scene: PackedScene = load("res://scenes/menu/menu.tscn")
var ship_setup_scene: PackedScene = load("res://scenes/menu/ship_setup.tscn")

var music_streams = {
    'A': ResourceLoader.load("res://music/SpaceFighter_A.mp3")
}

var state: String

func _ready():
    Globals.main = self
    state = 'start'
    music_player = get_node("MusicPlayer")
    for k in music_streams.keys():
        AudioServer.register_stream_as_sample(music_streams[k])
    
    var start = start_screen_scene.instantiate()
    start.main = self
    add_child(start)

func initiate_menu():
    state = 'menu'
    var start = get_node_or_null('Start')
    if start != null:
        start.queue_free()

    var level = level_scene.instantiate()
    level.is_menu_background = true
    add_child(level)

    if not music_player.playing:
        var stream = music_streams['A']
        music_player.stream = stream
        music_player.play()

    var menu = menu_scene.instantiate()
    add_child(menu)
    menu.find_child("StartGame").pressed.connect(Callable(close_menu).bind('ship_setup'))

func close_menu(next_scene: String):
    var level = get_node_or_null("Level")
    if level != null:
        level.start_fade_out()

    var menu = get_node_or_null("Menu")
    if menu != null:
        menu.queue_free()

    state = next_scene

func initiate_ship_setup():
    var ship_setup = ship_setup_scene.instantiate()
    add_child(ship_setup)

func receive_close_complete():
    if state == 'ship_setup':
        initiate_ship_setup()