extends Node

var quarterDuration : int = 1
var scoreGoal : int = -1
var duplicateChars : bool = false

var sfxVolume : float = 1.0
var musicVolume : float = 1.0

var locale : String = "en"

func _ready():
	pass

func set_quarter_duration(value : int):
	quarterDuration = value

func back_quarter_duration():
	match quarterDuration:
		5:
			set_quarter_duration(3)
		3:
			set_quarter_duration(1)
		1:
			set_quarter_duration(5)

func next_quarter_duration():
	match quarterDuration:
		1:
			set_quarter_duration(3)
		3:
			set_quarter_duration(5)
		5:
			set_quarter_duration(1)

func set_score_goal(value : int):
	scoreGoal = value

func back_score_goal():
	match scoreGoal:
		50:
			set_score_goal(21)
		21:
			set_score_goal(-1)
		-1:
			set_score_goal(50)

func next_score_goal():
	match scoreGoal:
		-1:
			set_score_goal(21)
		21:
			set_score_goal(50)
		50:
			set_score_goal(-1)

func set_allow_duplicate_chars(yes : bool):
	duplicateChars = yes

func set_sfx_volume(value : float):
	sfxVolume = snappedf(value, 0.1)
	AudioServer.set_bus_volume_db(audio.sfxBusIndex, linear_to_db(value))

func set_music_volume(value : float):
	musicVolume = snappedf(value, 0.1)
	AudioServer.set_bus_volume_db(audio.musicBusIndex, linear_to_db(value))

func set_locale(loc : String):
	if loc.is_empty():
		loc = "en"
	
	locale = loc
	TranslationServer.set_locale(loc)
