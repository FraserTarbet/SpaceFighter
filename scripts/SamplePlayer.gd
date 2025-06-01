class_name SamplePlayer

extends AudioStreamPlayer2D

var manager

func _ready():
	if manager:
		finished.connect(manager.free_player.bind(self))