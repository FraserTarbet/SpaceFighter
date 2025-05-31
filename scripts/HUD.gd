class_name HUD

extends Control

var health_bar: ProgressBar
var shield_bar: ProgressBar

func _ready():
    Globals.hud = self
    for child in get_children()[0].get_children()[0].get_children():
        if child.name == 'ShieldBar': 
            shield_bar = child
        elif child.name == 'HealthBar':
            health_bar = child
        

func _process(_delta):
    var player_ship = Globals.player_ship
    health_bar.value = (player_ship.health / player_ship.max_health) * 100
    shield_bar.value = (player_ship.shield.energy / player_ship.shield.max_energy) * 100