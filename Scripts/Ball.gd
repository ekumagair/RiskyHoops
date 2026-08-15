class_name Ball
extends Node3D

@onready var floorRayCast : RayCast3D = $FloorRayCast
@onready var horizontalRayCast : RayCast3D = $HorizontalRayCast

var held : bool = false
var scoring : bool = false
var slippery : bool = false
var velocity : Vector3 = Vector3(0, 10, 0)
var fallSpeed : float = 15.0
var fallSpeedBounceFactor : float = 0.6
var horizontalSpeedLoss : float = 4.0
var horizontalBounceFactor : float = 0.9
var forbidCharacter : Character
var ballDirection : Vector3 = Vector3(0, 1, 0)

func _process(delta : float) -> void:
	update_direction()

func _physics_process(delta : float) -> void:
	if is_on_floor() and forbidCharacter != null:
		forbidCharacter = null
	if scoring and forbidCharacter != null:
		forbidCharacter = null
	if is_on_floor() and scoring:
		held = false
		scoring = false
	
	if !held:
		gravity(delta)
		
		if !scoring:
			horizontal_velocity(delta)
			horizontal_bounce(delta)
	else:
		velocity = Vector3(0, 0, 0)
	
	translate(velocity * delta)

func gravity(delta : float):
	if !is_on_floor():
		velocity.y -= fallSpeed * delta
	elif absf(velocity.y) > 4.0:
		translate(Vector3(0, 0.2, 0))
		velocity.y *= absf(fallSpeedBounceFactor) * -1
	else:
		velocity.y = 0

func horizontal_velocity(delta : float):
	if slippery and is_on_floor():
		if velocity.x == 0:
			if randi_range(0, 1) == 0:
				velocity.x = 3
			else:
				velocity.x = -3
		
		velocity.x *= 1.001
		return
	
	if velocity.x > 0.05:
		velocity.x -= horizontalSpeedLoss * delta
	elif velocity.x < -0.05:
		velocity.x += horizontalSpeedLoss * delta
	else:
		velocity.x = 0
	
	if velocity.z > 0.05:
		velocity.z -= horizontalSpeedLoss * delta
	elif velocity.z < -0.05:
		velocity.z += horizontalSpeedLoss * delta
	else:
		velocity.z = 0

func horizontal_bounce(delta : float):
	if is_touching_wall() and (velocity.x != 0 or velocity.z != 0):
		translate(Vector3(-0.2 * ballDirection.x, 0, -0.2 * ballDirection.z))
		
		if ballDirection.x != 0:
			velocity.x *= horizontalBounceFactor * -1
		if ballDirection.z != 0:
			velocity.z *= horizontalBounceFactor * -1

func is_on_floor():
	return floorRayCast.is_colliding()

func is_touching_wall():
	return horizontalRayCast.is_colliding()

func update_direction():
	if velocity.x > 0:
		ballDirection.x = 1
	elif velocity.x < 0:
		ballDirection.x = -1
	
	if velocity.y > 0:
		ballDirection.y = 1
	elif velocity.y < 0:
		ballDirection.y = -1
	
	if velocity.z > 0:
		ballDirection.z = 1
	elif velocity.z < 0:
		ballDirection.z = -1
	
	horizontalRayCast.target_position = Vector3(ballDirection.x * 0.3, 0, ballDirection.z * 0.3)

func _on_slippery_area_entered(area: Area3D) -> void:
	slippery = true

func _on_slippery_area_exited(area: Area3D) -> void:
	slippery = false
