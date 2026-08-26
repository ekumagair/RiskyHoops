class_name UIMenu
extends Control

@export var screens : Array[UIScreen]
@export var screenDefault : String
@export var songsDefault : Array[Audio.Music]

var screenCurrent : UIScreen

func base_ready() -> void:
	get_tree().paused = false
	global.gManager = null
	
	for i in len(screens):
		screens[i].reset()
		screens[i].hide()
	
	go_to_screen(screenDefault)
	
	if len(songsDefault) > 0:
		audio.play_music(songsDefault.pick_random())

func go_to_screen(sName : String) -> void:
	for i in len(screens):
		if screens[i].name == sName:
			screens[i].reset()
			screens[i].open()
			screenCurrent = screens[i]
		else:
			screens[i].hide()

func get_screen(sName : String) -> UIScreen:
	for i in len(screens):
		if screens[i].name == sName:
			return screens[i]
	
	return null
