class_name CameraManager
extends Node3D

@export var cameraFollowTarget : Node3D
@export var cameraFollowSpeed : float = 10.0

@onready var camera : Camera3D = $Camera3D

var cameraDefaultPos : Vector3

func _ready() -> void:
	cameraDefaultPos = camera.global_position

func _physics_process(delta : float) -> void:
	camera_follow(delta)

func camera_follow(delta) -> void:
	if cameraFollowTarget == null:
		return
	
	var targetPos : Vector3 = cameraFollowTarget.global_position
	
	if targetPos.y * 3 > cameraDefaultPos.y:
		targetPos.y = cameraFollowTarget.global_position.y * 3
	else:
		targetPos.y = cameraDefaultPos.y
	
	if targetPos.y < cameraDefaultPos.y:
		targetPos.y = cameraDefaultPos.y
	if targetPos.y > cameraDefaultPos.y * 1.8:
		targetPos.y = cameraDefaultPos.y * 1.8
	
	targetPos.z = camera.global_position.z
	targetPos.x = clampf(targetPos.x, -7.5, 7.5)
	
	camera.global_position = camera.global_position.move_toward(targetPos, cameraFollowSpeed * delta)
