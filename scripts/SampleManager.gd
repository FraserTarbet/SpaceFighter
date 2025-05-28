extends Node2D

var player_count = 32
var free_players = []
var used_players = []
var sample_banks = {}
var sample_increment = 0
var rng = RandomNumberGenerator.new()

@export var pitch_mod: float = 0.2

func _ready():
    Globals.sample_manager = self

    # Register samples
    var path = "res://sounds"
    var dir = DirAccess.open(path)
    dir.list_dir_begin()
    var file = dir.get_next()
    while file != "":
        if file.ends_with(".wav"):
            var res = ResourceLoader.load(path + "/" + file)
            AudioServer.register_stream_as_sample(res)
            var bank = file.substr(0, file.rfind("_"))
            if not sample_banks.keys().has(bank):
                sample_banks[bank] = []
            sample_banks[bank].append(res)
        file = dir.get_next()

    # Create players
    for i in range(player_count):
        var player = SamplePlayer.new()
        player.manager = self
        free_players.append(player)
        add_child(player)

func play_sample_at(sample_bank_name: String, at: Vector2, level: float = 0.0):
    if free_players.size() == 0:
        print("No free sample players")
        return
    
    var player = free_players.pop_front()
    var bank = sample_banks[sample_bank_name]
    player.set_stream(bank[sample_increment % bank.size()])
    player.position = at
    player.volume_db = level

    player.pitch_scale = rng.randf_range(1.0 - pitch_mod, 1.0 +pitch_mod)

    player.play()

    used_players.append(player)
    sample_increment += 1

func free_player(player):
    used_players.erase(player)
    free_players.append(player)