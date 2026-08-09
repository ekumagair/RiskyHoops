class_name GameManager
extends Node

@export var baskets : Array[Basket]

@onready var camera : CameraManager = get_parent().get_node("CameraManager")
@onready var environment : Node3D = get_parent().get_node("Environment")

func _ready() -> void:
	global.gManager = self

func get_basket(team : int) -> Basket:
	for i in len(baskets):
		if baskets[i].team == team:
			return baskets[i]
	
	return null
