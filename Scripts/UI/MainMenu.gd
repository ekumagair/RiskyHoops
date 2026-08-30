class_name MainMenu
extends UIMenu

@export var btnChars : Array[ButtonCharacter]
@export var labelChars : Array[Label]

@onready var btnQuarterDuration : Button = $Main/Input/VBoxContainer/Button2
@onready var btnScoreGoal : Button = $Main/Input/VBoxContainer/Button3
@onready var btnMusVol : Button = $Main/Input/VBoxContainer/Button4
@onready var btnSfxVol : Button = $Main/Input/VBoxContainer/Button5
@onready var charSelectLabel : Label = $Chars/Input/MainLabel

var mainScreen : UIScreen
var charsScreen : UIScreen
var charsScreenFinishedRoot : Control
var currentCharIndex : int = 0
var isCpuSelecting : bool = false

func _ready() -> void:
	if !global.mainMenuFirstScreenOverride.is_empty() and global.mainMenuFirstScreenOverride != "":
		screenDefault = global.mainMenuFirstScreenOverride
	
	base_ready()
	mainScreen = get_screen("Main")
	charsScreen = get_screen("Chars")
	charsScreenFinishedRoot = charsScreen.get_node("OnFinished")

func _process(delta : float) -> void:
	update_button_text()
	
	if global.get_focus_owner() != null:
		if mainScreen.cursor != null and mainScreen.isOpen:
			mainScreen.cursor.global_position.x = 528
			mainScreen.cursor.global_position.y = global.get_focus_owner().global_position.y
		if charsScreen.cursor != null and charsScreen.isOpen:
			charsScreen.cursor.global_position.x = global.get_focus_owner().global_position.x + 140
	
	if screenCurrent == charsScreen and screenCurrent.isOpen and Input.is_action_just_pressed("ui_cancel"):
		go_to_main()

func go_to_main():
	go_to_screen("Main")

func go_to_char_select():
	go_to_screen("Chars")

func new_game():
	savedata.save_current_slot()
	
	global.charIds.clear()
	charsScreenFinishedRoot.hide()
	currentCharIndex = 0
	
	go_to_screen("Chars")
	#get_tree().change_scene_to_file("res://Maps/map_template.tscn")

#region Character Select
func let_player_select_character():
	charSelectLabel.show()
	
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
	
	var possibleChars : Array[ButtonCharacter]
	var selectedChar : ButtonCharacter
	
	possibleChars.clear()
	
	for i in len(btnChars):
		if (!global.charIds.has(btnChars[i].character) and !btnChars[i].chosen) or options.duplicateChars:
			possibleChars.append(btnChars[i])
	
	selectedChar = possibleChars.pick_random()
	selectedChar.chosen = true
	global.charIds.append(selectedChar.character)
	currentCharIndex += 1
	
	await get_tree().process_frame
	
	isCpuSelecting = false
	
	if currentCharIndex < 4:
		let_player_select_character()
	else:
		character_selection_ended()

func character_selected(char : GameConstants.Characters):
	if isCpuSelecting:
		return
	
	global.charIds.append(char)
	currentCharIndex += 1
	
	let_cpu_select_character()

func character_selection_ended():
	charsScreen.cursor.hide()
	charsScreen.inputRoot.hide()
	charSelectLabel.hide()
	charsScreenFinishedRoot.hide()
	
	for i in len(labelChars):
		labelChars[i].text = global.get_character_name(global.charIds[i])
	
	await charsScreen.play_animation("scroll_up")
	
	charsScreenFinishedRoot.show()
	
	var waitFrames : int = 300
	
	while !Input.is_anything_pressed() and waitFrames > 0:
		await get_tree().process_frame
		waitFrames -= 1
	
	await charsScreen.play_animation("close")
	
	audio.fade_music_to_silence()
	
	await get_tree().create_timer(1).timeout
	
	#get_tree().change_scene_to_file("res://Maps/map_template.tscn")
	get_tree().change_scene_to_file("res://Maps/map_risky_mountains.tscn")
#endregion

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
