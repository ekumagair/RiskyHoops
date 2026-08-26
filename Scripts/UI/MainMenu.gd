extends UIMenu

@export var btnChars : Array[ButtonCharacter]

@onready var btnQuarterDuration : Button = $Main/Input/VBoxContainer/Button2
@onready var btnScoreGoal : Button = $Main/Input/VBoxContainer/Button3
@onready var btnMusVol : Button = $Main/Input/VBoxContainer/Button4
@onready var btnSfxVol : Button = $Main/Input/VBoxContainer/Button5
@onready var charSelectLabel : Label = $Chars/Input/MainLabel

var mainScreen : UIScreen
var charsScreen : UIScreen
var currentCharIndex : int = 0
var isCpuSelecting : bool = false

func _ready() -> void:
	base_ready()
	mainScreen = get_screen("Main")
	charsScreen = get_screen("Chars")

func _process(delta : float) -> void:
	update_button_text()
	
	if global.get_focus_owner() != null:
		if mainScreen.cursor != null and mainScreen.isOpen:
			mainScreen.cursor.global_position.x = 528
			mainScreen.cursor.global_position.y = global.get_focus_owner().global_position.y
		if charsScreen.cursor != null and charsScreen.isOpen:
			charsScreen.cursor.global_position.x = global.get_focus_owner().global_position.x + 140

func go_to_main():
	go_to_screen("Main")

func go_to_char_select():
	go_to_screen("Chars")

func new_game():
	savedata.save_current_slot()
	global.charIds.clear()
	currentCharIndex = 0
	go_to_screen("Chars")
	#get_tree().change_scene_to_file("res://Maps/map_template.tscn")

func let_player_select_character():
	if currentCharIndex == 0:
		charSelectLabel.text = "PLAYER, CHOOSE YOUR CHARACTER"
	elif currentCharIndex == 2:
		charSelectLabel.text = "PLAYER, CHOOSE YOUR TEAMMATE"
	
	global.release_focus()
	charsScreen.cursor.hide()
	
	await get_tree().process_frame
	
	global.give_focus_to(btnChars[0].btn)
	charsScreen.cursor.show()

func let_cpu_select_character():
	isCpuSelecting = true
	global.release_focus()
	
	var possibleChars : Array[ButtonCharacter] = btnChars.duplicate()
	var selectedChar : ButtonCharacter
	
	if !options.duplicateChars:
		for i in 4:
			if i >= len(possibleChars):
				continue
			
			if global.charIds.has(possibleChars[i].character):
				possibleChars.erase(possibleChars[i])
	
	selectedChar = possibleChars.pick_random()
	global.charIds.append(selectedChar.character)
	currentCharIndex += 1
	
	await get_tree().process_frame
	
	isCpuSelecting = false
	
	if currentCharIndex < 4:
		let_player_select_character()
	else:
		charsScreen.cursor.hide()

func character_selected(char : GameConstants.Characters):
	if isCpuSelecting:
		return
	
	global.charIds.append(char)
	currentCharIndex += 1
	
	let_cpu_select_character()

func quit_game():
	savedata.save_current_slot()
	get_tree().quit()

func update_button_text():
	btnQuarterDuration.text = str(options.quarterDuration) + " MINUTE QUARTER"
	
	if options.scoreGoal > -1:
		btnScoreGoal.text = "PLAY TO " + str(options.scoreGoal) + " POINTS"
	else:
		btnScoreGoal.text = "TIMED PLAY"
	
	btnMusVol.text = "MUSIC VOLUME - " + str(int(options.musicVolume * 100))
	btnSfxVol.text = "SFX VOLUME - " + str(int(options.sfxVolume * 100))

func back_quarter_duration():
	options.back_quarter_duration()

func next_quarter_duration():
	options.next_quarter_duration()

func back_score_goal():
	options.back_score_goal()

func next_score_goal():
	options.next_score_goal()

func back_music_volume():
	if options.musicVolume > 0.0:
		options.set_music_volume(options.musicVolume - 0.1)

func next_music_volume():
	if options.musicVolume < 1.0:
		options.set_music_volume(options.musicVolume + 0.1)

func back_sfx_volume():
	if options.sfxVolume > 0.0:
		options.set_sfx_volume(options.sfxVolume - 0.1)

func next_sfx_volume():
	if options.sfxVolume < 1.0:
		options.set_sfx_volume(options.sfxVolume + 0.1)
