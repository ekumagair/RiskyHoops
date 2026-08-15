class_name UIMenu
extends Control

@export var screens : Array[UIScreen]
@export var screenDefault : String

var screenCurrent : UIScreen

func base_ready() -> void:
	get_tree().paused = false
	global.gManager = null
	
	for i in len(screens):
		screens[i].hide()
	
	go_to_screen(screenDefault)

func go_to_screen(sName : String) -> void:
	for i in len(screens):
		if screens[i].name == sName:
			screens[i].open()
			screenCurrent = screens[i]
