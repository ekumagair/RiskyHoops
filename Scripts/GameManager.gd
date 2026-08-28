class_name GameManager
extends Node

@export var baskets : Array[Basket]
@export var ball : Ball
@export var songs : Array[Audio.Music]

@onready var camera : CameraManager = get_parent().get_node("CameraManager")
@onready var environment : Node3D = get_parent().get_node("Environment")
@onready var objects : Node3D = get_parent().get_node("Objects")

var characters : Array[Node]
var charPosLimit : Vector3 = Vector3(13, 100, 7)
var score : Array[int]
var timeMin : int = 5
var timeSec : int = 0
var timeSecTenth : int = 9
var quarter : int = 1

var characterPrefabs = {
	-1: null,
	00: preload("res://Prefabs/character.tscn"),
	01: preload("res://Prefabs/character_rohan.tscn"),
	02: preload("res://Prefabs/character.tscn"),
	03: preload("res://Prefabs/character.tscn"),
	04: preload("res://Prefabs/character.tscn")
}

var attackPrefabs = {
	-1: null,
	00: preload("res://Prefabs/knife.tscn"),
}

func _ready() -> void:
	global.gManager = self
	get_characters()
	
	if len(songs) > 0:
		audio.play_music(songs.pick_random())
	
	score.clear()
	for i in 2:
		score.append(0)
	
	config_characters()
	config_rules()
	reduce_time()

func config_rules():
	timeMin = options.quarterDuration
	timeSec = 0
	timeSecTenth = 0

func config_characters():
	if len(global.charIds) < 1:
		return
	
	delete_characters()
	
	spawn_character_prefab(global.charIds[0], Vector3(-3, 0, -3), 0, 0)
	spawn_character_prefab(global.charIds[1], Vector3(3, 0, -3), -1, 1)
	spawn_character_prefab(global.charIds[2], Vector3(-3, 0, 3), -1, 0)
	spawn_character_prefab(global.charIds[3], Vector3(3, 0, 3), -1, 1)
	
	get_characters()

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

func release_ball(ball : Ball) -> void:
	get_characters()
	for i in len(characters):
		if characters[i].heldBall == ball:
			characters[i].heldBall = null

func get_attack_prefab(attack : GameConstants.Attacks):
	return attackPrefabs[int(attack)]

func reduce_time():
	await get_tree().create_timer(0.1).timeout
	
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
		quarter += 1
	
	reduce_time()
