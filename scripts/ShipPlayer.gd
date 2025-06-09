extends Ship

func _ready():
    # Don't think this runs when script is added to an existing node.
    super()
    Globals.player_ship = self

