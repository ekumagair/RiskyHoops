class_name GameCanvas
extends CanvasLayer

@export var playerName : Array[Label]
@export var scoreLabels : Array[Label]

@onready var timeMin : Label = $Control/Scoreboard/TimeMin
@onready var timeSec : Label = $Control/Scoreboard/TimeSec
@onready var quarterLabel : Label = $Control/Scoreboard/Quarter

func _ready() -> void:
	update_text()

func _process(delta : float) -> void:
	if Engine.get_process_frames() % 3 == 0:
		update_text()

func update_text():
	for i in len(playerName):
		playerName[i].text = "PLAYER " + str(i)
	
	for i in len(global.gManager.score):
		scoreLabels[i].text = str(global.gManager.score[i])
	
	timeMin.text = str(global.gManager.timeMin)
	
	if global.gManager.timeSec > 9:
		timeSec.text = str(global.gManager.timeSec)
	else:
		timeSec.text = "0" + str(global.gManager.timeSec)
	
	for i in len(global.charIds):
		scoreLabels[i].text = global.get_character_name(global.charIds[i])
