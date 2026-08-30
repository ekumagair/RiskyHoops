class_name Ball
extends Node3D

@onready var floorArea : Area3D = $FloorArea
@onready var horizontalRayCast : RayCast3D = $HorizontalRayCast
@onready var modelAnim : AnimationPlayer = $Model/AnimationPlayer

var held : bool = false
var holder : Character
var holderPrev : Character
var scoring : bool = false
var slippery : bool = false
var velocity : Vector3 = Vector3(0, 10, 0)
var fallSpeed : float = 15.0
var fallSpeedBounceFactor : float = 0.6
var horizontalSpeedLoss : float = 4.0
var horizontalBounceFactor : float = 0.8
var forbidCharacter : Character
var ballDirection : Vector3 = Vector3(0, 1, 0)
var releasePos : Vector3 = Vector3.ZERO
var twoPoint : bool = false

func _process(delta : float) -> void:
	update_direction()
	update_animation()

func _physics_process(delta : float) -> void:
	if global.gManager.gameState == GameManager.GameState.ENDED:
		return
	
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
		bounce_sound()
	else:
		velocity.y = 0

func bounce_sound():
	audio.play_sound(Audio.Sound.STOMP, global_position)

func horizontal_velocity(delta : float):
	if slippery and is_on_floor():
		if velocity.x == 0:
			if global_position.x < 0:
				velocity.x = 3
			else:
				velocity.x = -3
		
		if velocity.y == 0:
			velocity.y = randf_range(3, 6)
		
		velocity.x *= 1.01
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
	return floorArea.has_overlapping_bodies()

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

func update_animation():
	if held:
		if holder.is_on_floor():
			modelAnim.play("held")
		else:
			modelAnim.play("jump")
	else:
		modelAnim.play("default")
	
	if global.gManager.gameState == GameManager.GameState.ENDED:
		modelAnim.speed_scale = 0.0
	else:
		modelAnim.speed_scale = 1.0

func _on_slippery_area_entered(area: Area3D) -> void:
	slippery = true

func _on_slippery_area_exited(area: Area3D) -> void:
	slippery = false
