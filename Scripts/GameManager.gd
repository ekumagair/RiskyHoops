class_name GameManager
extends Node

@export var baskets : Array[Basket]
@export var ball : Ball
@export var songs : Array[Audio.Music]

@onready var camera : CameraManager = get_parent().get_node("CameraManager")
@onready var environment : Node3D = get_parent().get_node("Environment")
@onready var objects : Node3D = get_parent().get_node("Objects")

enum GameState
{
	DEFAULT,
	ORGANIZE,
	ENDED
}

var gameState : GameState = GameState.ORGANIZE
var characters : Array[Node]
var charPosLimit : Vector3 = Vector3(13, 100, 7)
var score : Array[int]
var timeMin : int = 5
var timeSec : int = 0
var timeSecTenth : int = 9
var quarter : int = 1
var paused : bool = false
var quitting : bool = false

var characterPrefabs = {
	-1: null,
	00: preload("res://Prefabs/character.tscn"),
	01: preload("res://Prefabs/character_rohan.tscn"),
	02: preload("res://Prefabs/character_skeleton.tscn"),
	03: preload("res://Prefabs/character_warrior.tscn"),
	04: preload("res://Prefabs/character_hoops.tscn")
}

var attackPrefabs = {
	-1: null,
	00: preload("res://Prefabs/projectile_knife.tscn"),
	01: preload("res://Prefabs/projectile_axe.tscn"),
}

func _ready() -> void:
	get_tree().paused = false
	paused = false
	quitting = false
	
	global.gManager = self
	global.mainMenuFirstScreenOverride = "Main"
	
	get_characters()
	
	if len(songs) > 0:
		audio.play_music(songs.pick_random())
	
	score.clear()
	for i in 2:
		score.append(0)
	
	config_characters()
	config_rules()
	reduce_time()
	
	organize_to_center()

func _process(delta : float) -> void:
	check_score_goal()

func config_rules():
	quarter = 1
	timeMin = options.quarterDuration
	timeSec = 0
	timeSecTenth = 0

func config_characters():
	if len(global.charIds) < 1:
		return
	
	delete_characters()
	
	spawn_character_prefab(global.charIds[0], Vector3(-9, 0, -3), 0, 0)
	spawn_character_prefab(global.charIds[1], Vector3(9, 0, -3), -1, 1)
	spawn_character_prefab(global.charIds[2], Vector3(-9, 0, 3), -1, 0)
	spawn_character_prefab(global.charIds[3], Vector3(9, 0, 3), -1, 1)
	
	get_characters()

func organize_to(pos : Array[Vector3]) -> void:
	gameState = GameState.ORGANIZE
	force_characters_as_cpu(true)
	
	await get_tree().create_timer(0.1).timeout
	
	get_characters()
	
	characters[0].targetWalkPos = pos[0]
	characters[1].targetWalkPos = pos[1]
	characters[2].targetWalkPos = pos[2]
	characters[3].targetWalkPos = pos[3]
	
	await wait_characters_organization()
	await get_tree().create_timer(0.3).timeout
	
	force_characters_as_cpu(false)
	gameState = GameState.DEFAULT

func organize_to_center():
	get_characters()
	
	var pos : Array[Vector3]
	pos.clear()
	pos.append(Vector3(-3, 0, -3))
	pos.append(Vector3(3, 0, -3))
	pos.append(Vector3(-3, 0, 3))
	pos.append(Vector3(3, 0, 3))
	
	characters[0].targetLookPos = 0
	characters[1].targetLookPos = 0
	characters[2].targetLookPos = 0
	characters[3].targetLookPos = 0
	
	organize_to(pos)

func organize_to_basket(team : int):
	get_characters()
	
	var basket : Basket = get_basket(team)
	var pos : Array[Vector3]
	pos.clear()
	
	if team == 0:
		pos.append(basket.positions[0].global_position)
		pos.append(basket.positions[1].global_position)
		pos.append(basket.positions[2].global_position)
		pos.append(basket.positions[3].global_position)
		
		characters[0].targetLookPos = -10
		characters[1].targetLookPos = -10
		characters[2].targetLookPos = -10
		characters[3].targetLookPos = -10
	elif team == 1:
		pos.append(basket.positions[1].global_position)
		pos.append(basket.positions[0].global_position)
		pos.append(basket.positions[3].global_position)
		pos.append(basket.positions[2].global_position)
		
		characters[0].targetLookPos = 10
		characters[1].targetLookPos = 10
		characters[2].targetLookPos = 10
		characters[3].targetLookPos = 10
	
	organize_to(pos)

func get_basket(team : int) -> Basket:
	for i in len(baskets):
		if baskets[i].team == team:
			return baskets[i]
	
	return null

func add_score(value : int, team : int):
	score[team] += value

func get_characters() -> void:
	characters = get_tree().get_nodes_in_group("characters")

func get_character_prefab(char : GameConstants.Characters):
	return characterPrefabs.get(int(char))

func spawn_character_prefab(char : GameConstants.Characters, globalPos : Vector3, playerId : int, team : int) -> void:
	if get_character_prefab(char) == null:
		return
	
	var instance = get_character_prefab(char).instantiate()
	
	objects.add_child(instance)
	instance.global_position = globalPos
	instance.playerId = playerId
	instance.team = team
	
	if instance.global_position.x > 0:
		instance.charDirection.x = -1
	else:
		instance.charDirection.x = 1

func delete_characters() -> void:
	get_characters()
	for i in len(characters):
		characters[i].queue_free()

func force_characters_as_cpu(enable : bool) -> void:
	get_characters()
	for i in len(characters):
		characters[i].forceCpuControl = enable

func release_ball(ball : Ball) -> void:
	get_characters()
	for i in len(characters):
		if characters[i].heldBall == ball:
			characters[i].release_ball(Vector3(0, 0, 0))
	
	ball.holderPrev = null
	ball.forbidCharacter = null

func teleport_ball_to(pos : Vector3) -> void:
	var ball : Ball = global.gManager.ball
	
	release_ball(ball)
	ball.set_deferred("global_position", pos)

func all_characters_reached_target() -> bool:
	for i in len(characters):
		if characters[i] == null or !characters[i].targetWalkReached:
			return false
	
	return true

func cancel_character_targets() -> void:
	for i in len(characters):
		characters[i].bot_cancel_target_pos()

func wait_characters_organization():
	await get_tree().create_timer(1).timeout
	
	while !all_characters_reached_target():
		await get_tree().process_frame

func get_attack_prefab(attack : GameConstants.Attacks):
	return attackPrefabs[int(attack)]

func reduce_time():
	await get_tree().create_timer(0.1).timeout
	
	if gameState == GameState.ENDED:
		return
	if gameState != GameState.DEFAULT:
		reduce_time()
		return
	while paused:
		if gameState == GameState.ENDED:
			return
		await get_tree().process_frame
	
	if timeSecTenth > 0:
		timeSecTenth -= 1
	else:
		timeSecTenth = 9
		
		if timeSec > 0:
			timeSec -= 1
		else:
			timeSec = 59
			
			if timeMin > 0:
				timeMin -= 1
	
	if timeMin <= 0 and timeSec <= 0:
		if quarter < 4 or score[0] == score[1]:
			end_quarter()
		else:
			end_match()
	
	reduce_time()

func end_quarter():
	if gameState == GameState.ORGANIZE:
		return
	
	quarter += 1
	organize_to_center()
	teleport_ball_to(Vector3(0, 0.4, 0))
	
	if quarter <= 4:
		global.gCanvas.organizeLabel.text = "END OF QUARTER"
	else:
		global.gCanvas.organizeLabel.text = "OVERTIME"
	
	timeMin = options.quarterDuration
	timeSec = 0
	timeSecTenth = 0
	
func end_match():
	if gameState == GameState.ENDED:
		return
	
	gameState = GameState.ENDED
	global.gCanvas.organizeLabel.text = "END OF MATCH"
	global.gManager.cancel_character_targets()
	global.gManager.get_characters()
	global.winners.clear()
	
	if score[0] > score[1]:
		global.winners.append(characters[0].characterId)
		global.winners.append(characters[2].characterId)
		global.winnerColor = Color(0, 0.216, 1, 1)
	elif score[1] > score[0]:
		global.winners.append(characters[1].characterId)
		global.winners.append(characters[3].characterId)
		global.winnerColor = Color(1, 0, 0, 1)
	
	await get_tree().create_timer(3).timeout
	
	audio.fade_music_to_silence(0.75)
	
	await global.gCanvas.end_match()
	
	get_tree().change_scene_to_file("res://Scenes/result_screen.tscn")

func check_score_goal():
	if options.scoreGoal < 1 or (gameState != GameState.DEFAULT and !global.gManager.ball.scoring):
		return
	
	if score[0] >= options.scoreGoal or score[1] >= options.scoreGoal:
		end_match()
