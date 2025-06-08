extends Node2D

@export var pop_in: float = 1.0
var pop_in_remaining: float
var fade_out_remaining

func _ready():
    pop_in_remaining = pop_in
    get_child(0).visible = false

func _process(delta):
    if pop_in_remaining <= 0.0:
        get_child(0).visible = true
    else:
        pop_in_remaining = max(pop_in_remaining - delta, 0.0)
