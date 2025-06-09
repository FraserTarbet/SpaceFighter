extends Node

var music_player: AudioStreamPlayer
var start_screen_scene: PackedScene = load("res://scenes/start.tscn")
var level_scene: PackedScene = load("res://scenes/level.tscn")
var menu_scene: PackedScene = load("res://scenes/menu/menu.tscn")
var ship_setup_scene: PackedScene = load("res://scenes/menu/ship_setup.tscn")
var hud_scene: PackedScene = load("res://scenes/HUD.tscn")

var music_streams = {
    'A': ResourceLoader.load("res://music/SpaceFighter_A.mp3")
}

var max_music_volume
var state: String

var level_params = {}

func _ready():
    Globals.main = self
    initiate_start()

func initiate_start():
    var hud = get_node_or_null("HUD")
    if hud != null:
        hud.queue_free()
        
    state = 'start'
    music_player = get_node("MusicPlayer")
    max_music_volume = music_player.volume_db
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
    menu.find_child("StartGame").pressed.connect(Callable(close).bind('ship_setup'))

func close(next_scene: String):
    var level = get_node_or_null("Level")
    if level != null:
        level.start_fade_out()

    var menu = get_node_or_null("Menu")
    if menu != null:
        menu.queue_free()

    var ship_setup = get_node_or_null("ShipSetup")
    if ship_setup != null:
        level_params['player_ship'] = ship_setup.get_selected_ship_name()
        ship_setup.start_fade_out()

    state = next_scene

func initiate_ship_setup():
    var ship_setup = ship_setup_scene.instantiate()
    add_child(ship_setup)
    ship_setup.find_child("Start").pressed.connect(Callable(close).bind('level'))

func receive_close_complete():
    if state == 'ship_setup':
        initiate_ship_setup()
    elif state == 'level':
        initiate_level()

func initiate_level():
    var level = level_scene.instantiate()
    level.is_menu_background = false
    level.params = level_params
    add_child(level)

    var hud = hud_scene.instantiate()
    add_child(hud)

func set_music_volume(percent: float):
    music_player.volume_db = lerpf(-60.0, max_music_volume, percent)