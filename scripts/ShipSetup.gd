extends Node

@export var ship_names: Array[String]
@export var ship_textures: Array[CanvasTexture]

var ship_index

func _ready():
    find_child("Prev").pressed.connect(prev_ship)
    find_child("Next").pressed.connect(next_ship)
    find_child("Back").pressed.connect(back)

    ship_index = randi_range(0, ship_names.size() - 1)
    update()

func update():
    find_child("ShipName").text = ship_names[ship_index]
    find_child("ShipTexture").texture = ship_textures[ship_index]

func prev_ship():
    ship_index = (ship_index - 1) % ship_names.size()
    update()

func next_ship():
    ship_index = (ship_index + 1) % ship_names.size()
    update()

func back():
    Globals.main.initiate_menu()
    queue_free()

func get_selected_ship_name():
    return ship_names[ship_index]