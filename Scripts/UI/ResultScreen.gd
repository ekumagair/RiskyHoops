class_name ResultScreen
extends UIMenu

@onready var winnerLabel1 : Label = $Result/Input/Winner1
@onready var winnerLabel2 : Label = $Result/Input/Winner2

var resultScreen : UIScreen

func _ready() -> void:
	global.mainMenuFirstScreenOverride = "Main"
	
	base_ready()
	resultScreen = get_screen("Result")
	
	if len(global.winners) > 0:
		winnerLabel1.text = global.get_character_name(global.winners[0])
		winnerLabel2.text = global.get_character_name(global.winners[1])
	
	winnerLabel1.modulate = global.winnerColor
	winnerLabel2.modulate = global.winnerColor
	
	global.winners.clear()
	global.charIds.clear()

func _process(delta : float) -> void:
	if Input.is_anything_pressed() and resultScreen.isOpen:
		resultScreen.close()

func fade_to_main_menu():
	audio.fade_music_to_silence()

func go_to_main_menu():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
