class_name Ball
extends Node3D

@onready var floorRayCast : RayCast3D = $FloorRayCast

var held : bool = false
var velocity : Vector3 = Vector3(0, 10, 0)
var fallSpeed : float = 15.0
var fallSpeedBounceFactor : float = 0.6

func _physics_process(delta : float) -> void:
	if !held:
		gravity(delta)
	else:
		velocity = Vector3(0, 0, 0)
	
	translate(velocity * delta)

func gravity(delta : float):
	if !is_on_floor():
		velocity.y -= fallSpeed * delta
	elif absf(velocity.y) > 0.5:
		velocity.y *= absf(fallSpeedBounceFactor) * -1
	else:
		velocity.y = 0

func is_on_floor():
	return floorRayCast.is_colliding()
