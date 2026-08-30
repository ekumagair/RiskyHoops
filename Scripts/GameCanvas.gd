class_name GameCanvas
extends CanvasLayer

@export var playerName : Array[Label]
@export var scoreLabels : Array[Label]

@onready var timeMin : Label = $Control/Scoreboard/TimeMin
@onready var timeSec : Label = $Control/Scoreboard/TimeSec
@onready var quarterLabel : Label = $Control/Scoreboard/Quarter
@onready var organizeLabel : Label = $Control/Organize/Label
@onready var fadeImg : TextureRect = $Control/Fade
@onready var fadeAnim : AnimationPlayer = $Control/Fade/AnimationPlayer
@onready var pauseRoot : Control = $Control/Pause
@onready var pauseCursor : TextureRect = $Control/Pause/Cursor
@onready var pauseBtnContinue : ButtonComplement = $Control/Pause/ButtonGeneric
@onready var pauseBtnQuit : ButtonComplement = $Control/Pause/ButtonGeneric2

func _ready() -> void:
	global.gCanvas = self
	organizeLabel.text = ""
	fadeImg.modulate = Color(0, 0, 0, 0)
	pauseRoot.hide()
	
	update_text()

func _process(delta : float) -> void:
	if Engine.get_process_frames() % 3 == 0:
		update_text()
	
	process_pause()

func update_text():
	for i in len(global.gManager.score):
		scoreLabels[i].text = str(global.gManager.score[i])
	
	timeMin.text = str(global.gManager.timeMin)
	
	if global.gManager.timeSec > 9:
		timeSec.text = str(global.gManager.timeSec)
	else:
		timeSec.text = "0" + str(global.gManager.timeSec)
	
	if len(global.charIds) > 0:
		for i in len(global.charIds):
			playerName[i].text = global.get_character_name(global.charIds[i])
	else:
		for i in len(playerName):
			playerName[i].text = "PLAYER " + str(i)
	
	quarterLabel.text = "QUARTER " + str(global.gManager.quarter)
	
	organizeLabel.visible = global.gManager.gameState != GameManager.GameState.DEFAULT
	
	if !organizeLabel.visible:
		organizeLabel.text = ""

func play_fade_animation(animName : String):
	if fadeAnim != null:
		fadeAnim.play(animName)
		await fadeAnim.animation_finished

func fade_in():
	await play_fade_animation("fade_in")

func end_match():
	await fade_in()

func process_pause():
	if global.gManager.quitting or global.gManager.gameState == GameManager.GameState.ENDED:
		return
	
	if Input.is_action_just_pressed("ui_cancel"):
		if global.gManager.paused:
			unpause()
		else:
			pause()
	
	if global.gManager.paused:
		if pauseCursor != null and global.get_focus_owner() != null:
			pauseCursor.position.y = global.get_focus_owner().position.y

func pause():
	pauseRoot.show()
	pauseCursor.show()
	
	pauseBtnContinue.disabled = false
	pauseBtnQuit.disabled = false
	
	global.gManager.paused = true
	global.give_focus_to(pauseBtnContinue)
	audio.pause_music(true)
	
	get_tree().paused = true

func unpause():
	pauseRoot.hide()
	
	global.gManager.paused = false
	global.release_focus()
	audio.pause_music(false)
	
	get_tree().paused = false

func pause_quit():
	pauseCursor.hide()
	
	global.release_focus()
	global.gManager.gameState = GameManager.GameState.ENDED
	global.gManager.quitting = true
	
	pauseBtnContinue.disabled = true
	pauseBtnQuit.disabled = true
	
	await fade_in()
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
