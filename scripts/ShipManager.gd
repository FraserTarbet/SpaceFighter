extends Node

var ships = []
var friendly_ships = []
var enemy_ships = []

func add_ship(ship):
    if not ships.has(ship):
        ships.append(ship)

    if ship.is_enemy:
        if not enemy_ships.has(ship):
            enemy_ships.append(ship)
    else:
        if not friendly_ships.has(ship):
            friendly_ships.append(ship)

func remove_ship(ship):
    for list in [ships, friendly_ships, enemy_ships]:
        if list.has(ship):
            list.remove(ship)