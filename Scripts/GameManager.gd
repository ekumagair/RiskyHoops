class_name GameManager
extends Node

@export var baskets : Array[Basket]

@onready var camera : CameraManager = get_parent().get_node("CameraManager")
@onready var environment : Node3D = get_parent().get_node("Environment")
@onready var objects : Node3D = get_parent().get_node("Objects")

var characters : Array[Node]

func _ready() -> void:
	global.gManager = self
	get_characters()

func get_basket(team : int) -> Basket:
	for i in len(baskets):
		if baskets[i].team == team:
			return baskets[i]
	
	return null

func get_characters() -> void:
	characters = get_tree().get_nodes_in_group("characters")

func delete_characters() -> void:
	get_characters()
	for i in len(characters):
		characters[i].queue_free()

func release_ball(ball : Ball) -> void:
	get_characters()
	for i in len(characters):
		if characters[i].heldBall == ball:
			characters[i].heldBall = null
