class_name UIMenu
extends Control

@export var screens : Array[UIScreen]
@export var screenDefault : String

var screenCurrent : UIScreen

func base_ready() -> void:
	get_tree().paused = false
	global.gManager = null
	
	for i in len(screens):
		screens[i].reset()
		screens[i].hide()
	
	go_to_screen(screenDefault)

func go_to_screen(sName : String) -> void:
	for i in len(screens):
		if screens[i].name == sName:
			screens[i].reset()
			screens[i].open()
			screenCurrent = screens[i]
		else:
			screens[i].hide()
