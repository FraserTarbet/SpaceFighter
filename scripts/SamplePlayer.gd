class_name SamplePlayer

extends AudioStreamPlayer2D

var manager

func _ready():
	# set_playback_type(AudioServer.PLAYBACK_TYPE_SAMPLE)
	finished.connect(manager.free_player.bind(self))