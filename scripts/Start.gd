extends Control

var main

func _input(event):
    if event is InputEventKey or event is InputEventScreenTouch:
        main.initiate_menu()